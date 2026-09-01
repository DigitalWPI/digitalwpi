class ImportFilesetService
  include ImportHelper
  attr_reader :file_path, :base_dir, :metadata
  attr_accessor :parent_work

  def initialize(file_path, base_dir)
    @file_path = file_path
    @base_dir = base_dir
    @metadata = parse_metadata_file(@file_path)
  end

  def call
    if parent_work.present?
      fileset = create_fileset
      attach_file_to_fileset(fileset)
      attach_fileset_to_work(fileset)
      fileset.save!
      puts "Imported FileSet: #{fileset.id} for Work: #{parent_work.id}"
    else
      puts "Work with old ID #{work_id} not found. Skipping FileSet import."
    end
  end

  private

  def parent_work
    work_id = metadata["parent_work_id"]
    parent_work ||= Hyrax.query_service.find_by(id: work_id) if work_id.present?
  end

  def create_fileset
    # Implement logic to create a new FileSet object and associate it with the given Work
  end

  def attach_file_to_fileset(fileset)
    # Implement logic to attach the actual file to the FileSet based on the metadata
  end

  def attach_fileset_to_work(fileset)
    # Implement logic to associate the FileSet with the Work
  end
end