require 'json'
require 'csv'
require 'date'
require 'pathname'

class AddJpegToWorks
  attr_reader :csv, :new_fileset_ids
  attr_accessor :output_csv_file, :processed_fileset_ids
    def initialize(input_csv_file, output_dir: "log", processed_fileset_ids: [], max_count: 0, purge_tiff: false,
                   fileset_id_prefix: "05a2", filter_by_collections: ["hi"])
    @input_csv_file = input_csv_file
    @output_dir = output_dir
    @output_csv_file = File.join(@output_dir, "attach_jpg_to_work_output.csv")
    @processed_fileset_ids = processed_fileset_ids
    headers = %w(time tiff_fileset_id digest_ssim tiff_filepath jpg_filepath	note work_id jpg_fileset_id
                 jpg_added message tiff_purged)
    @csv = CSV.open(@output_csv_file, "ab", :headers => headers, :write_headers => true)
    @count = 0
    @max_count = max_count
    @purge_tiff = purge_tiff
    @depositor = User.find_by_user_key("depositor@wpi.edu")
    @new_fileset_ids = []
    @fileset_id_prefix = fileset_id_prefix
    @filter_by_collections = filter_by_collections
    gather_ids_from_output_csv
  end

  def add_from_csv
    raise Exception.new("File #{@input_csv_file} not Found") unless File.exist?(@input_csv_file)
    table = CSV.parse(File.read(@input_csv_file), headers: true)
    table.by_row.each do |csv_row|
      next if @processed_fileset_ids.include?(csv_row['tiff_fileset_id'])
      @count = @count + 1
      return if @max_count > 0 and @count > @max_count
      row = set_row_defaults(csv_row)
      next unless jpg_file_exists?(row)
      tiff_fileset = get_tiff_fileset(row)
      next unless tiff_fileset.present?
      work_ids = get_work_ids(tiff_fileset, row)
      next unless work_ids.present?
      embargo_attributes = get_embargo_from_tiff_fileset(tiff_fileset)
      title = [get_title_from_tiff_fileset(tiff_fileset, row)]
      # title = [File.basename(row['jpg_filepath'])]
      work_ids.each do |work_id|
        row = set_row_defaults(csv_row, work_id: work_id)
        row, added_jpg = add_jpg_to_work_id(work_id, title, embargo_attributes, row)
        if @purge_tiff and added_jpg
          purge_tiff_fileset(tiff_fileset, row)
        else
          @csv << row
        end
      end
    end
    @csv.close
  end

  def purge_all_tiffs
    raise Exception.new("File #{@input_csv_file} not Found") unless File.exist?(@input_csv_file)
    table = CSV.parse(File.read(@input_csv_file), headers: true)
    table.by_row.each do |csv_row|
      row = set_purge_row_defaults(csv_row)
      if csv_row['jpg_added']
        id = row['tiff_fileset_id']
        purge_tiff_fileset(id, row, by_id=true)
      end
    end
    @csv.close
  end

  private

  def gather_ids_from_output_csv
    if File.exist?(@output_csv_file)
      table = CSV.parse(File.read(@output_csv_file), headers: true)
      table.by_row.each do |csv_row|
        @processed_fileset_ids.append(csv_row['tiff_fileset_id']) if csv_row['tiff_fileset_id'].present?
        @new_fileset_ids.append(csv_row['jpg_fileset_id']) if csv_row['jpg_fileset_id'].present?
      end
      @processed_fileset_ids.uniq!
      @new_fileset_ids.uniq!
    end
  end

  def set_row_defaults(row, work_id: '')
    new_row = row.to_hash
    new_row['time'] = DateTime.now().strftime("%Y-%m-%d %H:%M:%S")
    new_row['work_id'] = work_id
    new_row['jpg_fileset_id'] = ''
    new_row['jpg_added'] = false
    new_row['message'] = ''
    new_row['tiff_purged'] = false
    new_row
  end

  def set_purge_row_defaults(row)
    new_row = row.to_hash
    new_row['time'] = DateTime.now().strftime("%Y-%m-%d %H:%M:%S")
    new_row
  end

  def purge_tiff_fileset(tiff_fileset, row, by_id=false)
    if by_id
      id = tiff_fileset
    else
      id = tiff_fileset.id
      tiff_fileset.delete()
    end
    # extrapolate the id for Fedora
    pair_tree = "#{id[0..1]}/#{id[2..3]}/#{id[4..5]}/#{id[6..7]}"
    repository = Rails.application.config_for(:fedora)["url"]
    uri = "#{repository}/prod/#{pair_tree}/#{id}"
    msg, state = purge_from_fedora_using_curl(uri)
    if state and File.exist?(row['tiff_filepath'])
      # Delete file if it exists
      p = ::Pathname.new(row['tiff_filepath'])
      `sudo chmod -R 777 "#{p.parent.to_s}"`
      File.delete(row['tiff_filepath'])
      `sudo chmod -R 755 "#{p.parent.to_s}"`
      msg = msg + ". Tiff file deleted from disk"
    end
    row['message'] = "#{row['message']}. #{msg}"
    row['tiff_purged'] = state
    @csv << row
  end

  def purge_from_fedora_using_curl(uri)
    begin
      del_status = false
      tomb_status = false
      del_code = `curl -X DELETE -o /dev/null -s -w "%{http_code}" "#{uri}"`.to_i
      tomb_code = `curl -X DELETE -o /dev/null -s -w "%{http_code}" "#{uri}/fcr:tombstone"`.to_i
      if del_code == 404 or (del_code >= 200 and del_code < 300)
        del_status = true
      end
      if tomb_code == 404 or (tomb_code >= 200 and tomb_code < 300)
        tomb_status = true
      end
      if (del_status and tomb_status) or tomb_status
        return "Tiff fileset purged from Fedora", true
      else
        return "Tiff fileset not purged - delete http status #{del_code}, tombstone http status #{tomb_code} ", false
      end
    rescue Exception => ex
      return "Tiff fileset not purged: #{ex.to_s}", false
    end
  end

  def add_jpg_to_work_id(work_id, title, embargo_attributes, row)
    work = get_work(work_id, row)
    unless work.present?
      row['message'] = "Work not found"
      return row, false
    end
    unless work_belongs_to_collection?(work)
      row['message'] = "Work does not belong to chosen collection"
      return row, false
    end
    if work_has_jpeg?(work)
      row['message'] = "Work already has jpeg file. So not adding"
      return row, false
    end
    # uploaded_file = upload_file(row['jpg_filepath'])
    jpg_fileset_id = nil
    begin
      jpg_fileset_id = create_fileset(work, row['jpg_filepath'], title, embargo_attributes)
      set_work_thumbnail(work, jpg_fileset_id)
      row['jpg_fileset_id'] = jpg_fileset_id
      row['jpg_added'] = true
      row['message'] = "Added jpg file to work"
      return row, true
    rescue Exception => ex
      row['jpg_fileset_id'] = jpg_fileset_id
      row['message'] = ex.to_s
      return row, false
    end
  end

  def get_work(work_id, row)
    work = ActiveFedora::Base.find(work_id)
    unless work.present?
      row['message'] = "Work #{work_id} is not found"
      @csv << row
      return nil
    end
    work
  end

  def jpg_file_exists?(row)
    unless row['jpg_filepath'].present?
      row['message'] = row['note']
      @csv << row
      return false
    end
    # check if jpeg file represented by jpg_filepath is present
    unless row['jpg_filepath'].present? and File.exist?(row['jpg_filepath'])
      row['message'] = "Jpeg file not found"
      @csv << row
      return false
    end
    true
  end

  def get_tiff_fileset(row)
    # Get existing tiff fileset
    fileset = FileSet.find(row['tiff_fileset_id'])
    fileset
  rescue Ldp::Gone => e
    row['message'] = "Fileset has been deleted #{row['tiff_fileset_id']}"
    @csv << row
    return nil
  rescue => e
    row['message'] = "Fileset not found #{row['tiff_fileset_id']}"
    @csv << row
    return nil
  end

  def get_work_ids(tiff_fileset, row)
    work_ids = tiff_fileset.parent_work_ids.uniq
    unless work_ids.present?
      row['message'] = "Fileset #{row['tiff_fileset_id']} has no parent work"
      @csv << row
    end
    work_ids
  end

  def work_belongs_to_collection?(work)
    in_collection = false
    @filter_by_collections.each do |col_id|
      in_collection = true if (work.member_of_collection_ids.include?(col_id) or work.parent_collection_ids.include?(col_id))
    end
    in_collection
  end

  def work_has_jpeg?(work)
    has_jpeg = false
    work.file_sets.each do |fs|
      if fs.mime_type == 'image/jpeg' or fs.title.first.end_with?('.jpg') or fs.title.first.end_with?('.jpeg')
        has_jpeg = true
      end
    end
    has_jpeg
  end

  def get_embargo_from_tiff_fileset(fileset)
    embargo_attributes = {
      'embargo' => false,
      'embargo_release_date' => nil
    }
    if fileset.embargo.present?
      if fileset.embargo.id.present? || fileset.embargo.embargo_release_date.present?
        embargo_attributes['embargo'] = true
        if fileset.embargo.embargo_release_date.present?
          embargo_attributes['embargo_release_date'] = fileset.embargo.embargo_release_date
        else
          embargo_attributes['embargo_release_date'] = '2100-01-01'
        end
      end
    end
    embargo_attributes
  end

  def get_title_from_tiff_fileset(tiff_fileset, row)
    tiff_titles = tiff_fileset.title.reject(&:blank?)
    if tiff_titles.present?
      title = tiff_titles.first
      title = "#{File.basename(title, ".tif")}.jpg" if title.end_with?('.tif')
    else
      title = File.basename(row['jpg_filepath'])
    end
    title
  end

  def _upload_file(filepath)
    u = ::Hyrax::UploadedFile.new
    u.user = @depositor unless @depositor.nil?
    u.file = ::CarrierWave::SanitizedFile.new(filepath)
    u.save
    u
  end

  def create_fileset(work, jpg_filepath, title, embargo_attributes)
    fs = FileSet.new
    new_id = generate_new_id
    @new_fileset_ids << new_id
    fs.id = new_id
    # ActiveFedora::Noid::Service.new.mint
    fs.title = title
    fs.permissions_attributes = work.permissions.map(&:to_hash)
    if embargo_attributes['embargo'] == true
      fs.apply_embargo(embargo_attributes['embargo_release_date'],
                       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE,
                       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
    end
    fs.set_edit_groups(["content-admin"], [])
    actor = ::Hyrax::Actors::FileSetActor.new(fs, @depositor)
    actor.create_metadata
    actor.create_content(File.open(jpg_filepath, 'rb'))
    fs.save
    actor.attach_to_work(work)
    fs.id
  end

  def generate_new_id
    new_id = "#{@fileset_id_prefix}#{SecureRandom.uuid[0..4]}"
    generate_new_id if @new_fileset_ids.include?(new_id)
    new_id
  end

  def set_work_thumbnail(work, jpg_fileset_id)
    work.representative_id = jpg_fileset_id
    work.thumbnail_id = jpg_fileset_id
    work.save
  end
end

# To use
# input_csv_file = '/home/webapp/id_hash_file_mapping.csv'
# max_count = 1000
# purge_tiff = true
# a = AddJpegToWorks.new(input_csv_file,
#                        max_count: max_count,
#                        purge_tiff: purge_tiff)
# a.add_from_csv

