class ImportCollectionService
  include ImportHelper
  attr_reader :file_path, :base_dir, :metadata

  def initialize(file_path, base_dir)
    @file_path = file_path
    @base_dir = base_dir
    @collection_ids = get_collection_id_mappings
    @metadata = parse_metadata_file(file_path)
  end

  def call
    Rails.logger.info("Step 1/4 - Importing collection #{metadata["id"]}")
    new_id =  @collection_ids.fetch(metadata["id"], nil)
    collection = Collection.find_by(id: new_id)
    collection ||= Collection.new(id: new_id || nil)
    collection.title = metadata["title_tesim"]
    collection.description = metadata["description_tesim"]
    collection.depositor = metadata["depositor_tesim"]
    # Visibility
    collection.visibility = metadata["visibility_ssi"]
    # Access
    collection.read_groups = metadata["read_access_group_ssim"] if metadata.fetch("read_access_group_ssim", []).present?
    collection.edit_groups = metadata["edit_access_group_ssim"] if metadata.fetch("edit_access_group_ssim", []).present?
    collection.edit_users = metadata["edit_access_person_ssim"] if metadata.fetch("edit_access_person_ssim", []).present?
    # ToDo - Collection type - All the collections are likely user collections. hard coding gid for now
    # collection.admin_set_id = Hyrax.config.default_admin_set.id.to_s
    # collection.collection_type_gid = metadata["collection_type_gid_ssim"].first if metadata["collection_type_gid_ssim"].present?
    collection.collection_type_gid = "gid://digital-wpi/Hyrax::CollectionType/2"
    # ToDo - Set thumbnail path
    # "thumbnail_path_ss": "/downloads/xk81jn86b?file=thumbnail",
    # hasRelatedImage_ssim
    collection.save(index: true)
  end

  def add_members
    new_id =  @collection_ids.fetch(metadata["id"], nil)
    collection = Collection.find_by(id: new_id)
    if collection.present? and metadata["nesting_collection__parent_ids_ssim"].present?
      Rails.logger.info("Setting collection members for #{metadata["id"]}")
      member_added = false
      metadata["nesting_collection__parent_ids_ssim"].each do |parent_id|
        new_parent_id = @collection_ids.fetch(parent_id, nil)
        if new_parent_id.present?
          # ToDo - Do we need to set both?
          collection.member_of_collection_ids << new_parent_id
          collection.member_ids << new_parent_id
          member_added = true
        else
          Rails.logger.error("Collection - #{new_id}. Parent collection id #{parent_id} not found. Not adding parent.")
        end
      end
      collection.save(index: true) if member_added
    end
  end
end