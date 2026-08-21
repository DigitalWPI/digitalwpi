class ImportUserService
  def initialize(file_path, base_dir)
    @file_path = file_path
    @base_dir = base_dir
    @metadata = parse_metadata_file(@file_path)
  end

  def call
    # Implementation for importing user
  end
end