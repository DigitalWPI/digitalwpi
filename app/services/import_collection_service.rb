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
    #collection.admin_set_id = Hyrax.config.default_admin_set.id.to_s
    collection.collection_type_gid = metadata["collection_type_gid_ssim"].first if metadata["collection_type_gid_ssim"].present?
    collection.title = metadata["title_tesim"]
    collection.description = metadata["description_tesim"]
    collection.depositor = metadata["depositor_tesim"]
    collection.save(index: true)
  end
end