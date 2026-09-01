class ImportUserService
  include ImportHelper
  attr_reader :file_path, :base_dir, :metadata

  def initialize(file_path, base_dir)
    @file_path = file_path
    @base_dir = base_dir
    @metadata = parse_metadata_file(file_path)
  end

  def call
    new_user = User.find_or_initialize_by(email: metadata["email"])

    if new_user.new_record?
      new_user.encrypted_password = metadata["encrypted_password"]
      new_user.display_name = metadata["display_name"]
      new_user.save!(validate: false)
    end

    assign_roles_to_user(new_user)
  end

  def assign_roles_to_user(user)
    return unless metadata["roles"].present?

    metadata["roles"].each do |role_name|
      role = Role.find_or_create_by(name: role_name)
      user.roles << role unless user.roles.include?(role)
    end
  end
end