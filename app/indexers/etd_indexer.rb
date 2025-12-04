# Generated via
#  `rails generate hyrax:work Etd`
class EtdIndexer < Hyrax::WorkIndexer
  # This indexes the default metadata. You can remove it if you want to
  # provide your own metadata and indexing.
  include Hyrax::IndexesBasicMetadata
  include IndexerHelper

  # Fetch remote labels for based_near. You can remove this if you don't want
  # this behavior
  include Hyrax::IndexesLinkedMetadata

  def generate_solr_document
    super.tap do |solr_doc|
      solr_doc['license_sim'] = object.license
      solr_doc['all_metadata_tesim'] = all_metadata_values
      solr_doc['title_ansort'] = object.title.first
    end
  end
end
