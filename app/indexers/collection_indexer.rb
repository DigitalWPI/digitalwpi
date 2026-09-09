# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:collection_resource Collection`
class CollectionIndexer < Hyrax::Indexers::PcdmCollectionIndexer
  include Hyrax::Indexer(:collection)

  def to_solr
    super.tap do |index_document|
      index_document['title_ansort'] = resource.title.first
    end
  end
end
