class ImportRoleService
  def initialize(file_path, base_dir)
    @file_path = file_path
    @base_dir = base_dir
    @metadata = parse_metadata_file(@file_path)
  end

  def call
    return unless @metadata["name"].present?
    role = Role.find_or_create_by(name: @metadata["name"])
  end
end