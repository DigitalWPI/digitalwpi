class CollectionIndexer < Hyrax::CollectionWithBasicMetadataIndexer
  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['title_ansort'] = object.title.first
    end
  end
end