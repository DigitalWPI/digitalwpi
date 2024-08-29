require 'json'
require 'csv'

class AddJpegToWorks
  def initialize(input_csv_file, output_dir: "log", processed_fileset_ids: [], max_count: 0)
    @input_csv_file = input_csv_file
    @output_dir = output_dir
    time = Time.now.strftime("%Y-%m-%d_%H-%M-%S")
    @output_csv_file = File.join(@output_dir, "attach_jpg_to_work_output-#{time}.csv")
    @processed_fileset_ids = processed_fileset_ids
    headers = %w(time	fileset_id digest_ssim tiff_filepath jpg_filepath	note jpg_added message work_id new_fileset_id)
    @csv = CSV.open(@output_csv_file, "ab", :headers => headers, :write_headers => true)
    @count = 0
    @max_count = max_count
  end

  def add_from_csv
    raise Exception.new("File #{@input_csv_file} not Found") unless File.exist?(@input_csv_file)
    table = CSV.parse(File.read(@input_csv_file), headers: true)
    user = User.find_by_user_key("depositor@wpi.edu")
    table.by_row.each do |row|
      next if @processed_fileset_ids.include?(row['fileset_id'])
      @count = @count + 1
      return if @max_count > 0 and @count > @max_count
      adding_jpg = true
      # jpg_filepath is not present
      unless row['jpg_filepath'].present?
        row['message'] = row['note']
        row['jpg_added'] = false
        adding_jpg = false
      end
      # jpeg file represented by jpg_filepath is not present
      unless row['jpg_filepath'].present? and File.exist?(row['jpg_filepath'])
        row['message'] = "Jpeg file not found"
        row['jpg_added'] = false
        adding_jpg = false
      end
      # If no jpg file, write to csv and go to the next one
      unless adding_jpg
        @csv << row
        next
      end
      add_jpeg_to_tiff(row, user)
    end
    @csv.close
  end

  private

  def add_jpeg_to_tiff(row, user)
    fileset_id = row['fileset_id']
    jpg_filepath = row['jpg_filepath']

    fileset = FileSet.find(fileset_id)
    unless fileset.present?
      row['message'] = "Fileset not found #{fileset_id}"
      row['jpg_added'] = false
      @csv << row
      return
    end
    work_ids = fileset.parent_work_ids.uniq

    work_ids.each do |work_id|
      row['work_id'] = work_id
      work = ActiveFedora::Base.find(work_id)
      if work.present?
        if work_has_jpeg?(work)
          row['message'] = "Work already has jpeg file. So not adding"
          row['jpg_added'] = false
          @csv << row
        else
          embargo_attributes = tiff_fileset_embargo_attributes(fileset)
          new_fileset_id = nil
          begin
            new_fileset_id = attach_jpeg_file(work, user, jpg_filepath, fileset.title, embargo_attributes)
            row['new_fileset_id'] = new_fileset_id
            row['jpg_added'] = true
            row['message'] = "Added jpg file to work"
            @csv << row
          rescue Exception => e
            row['new_fileset_id'] = new_fileset_id
            row['jpg_added'] = false
            row['message'] = e.message
            @csv << row
          end
        end
      else
        row['message'] = "Work #{work_id} associated with Fileset #{fileset_id} is not found"
        row['jpg_added'] = false
        @csv << row
      end
    end
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

  def tiff_fileset_embargo_attributes(fileset)
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

  def attach_jpeg_file(work, user, file_path, title, embargo_attributes)
    fs = FileSet.new
    fs.id = ActiveFedora::Noid::Service.new.mint
    fs.title = title
    actor = ::Hyrax::Actors::FileSetActor.new(fs, user)
    actor.create_metadata
    actor.create_content(File.open(file_path))
    actor.attach_to_work(work)
    if embargo_attributes['embargo'] == true
      fs.apply_embargo(embargo_attributes['embargo_release_date'],
                       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE,
                       Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC)
    end
    fs.set_edit_groups(["content-admin"], [])
    fs.save
    fs.id
  end
end