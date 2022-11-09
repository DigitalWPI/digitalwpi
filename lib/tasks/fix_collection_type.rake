require 'json'

namespace :wpi do
  desc 'Fix collection type to match Hyrax 3. usage: wpi:fix_collection_type'
  task fix_collection_type: :environment do
    new_collection_type_gid = Hyrax::CollectionType.find_by_title('Nestable Collection').gid
    old_collection_type_gid = "gid://digital-wpi/hyrax-collectiontype/1"
    errors = {}
    Collection.find_each do |collection|
      next unless collection.collection_type_gid == old_collection_type_gid
      begin
        collection.send(:collection_type_gid=, new_collection_type_gid, force: true)
        collection.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
        collection.save
      rescue => e
        errors[collection.id] = e.message
      end
    end
    JSON.pretty_generate(errors) if errors
  end
end
