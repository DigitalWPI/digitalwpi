# Generated via
#  `rails generate hyrax:work GenericWork`
class GenericWorkIndexer < Hyrax::WorkIndexer
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
<<<<<<< HEAD
     solr_doc['title_ansort'] = object.title.first
<<<<<<< HEAD
     solr_doc['year_sim'] = object.year.strip[0,4] if object.year
=======
=======
     solr_doc['year_sim'] = object.year.strip[0,4] if object.year
>>>>>>> fd027a4 (Add just the first 4 digits to year and ignore range)
>>>>>>> a8ff9f8 (Add just the first 4 digits to year and ignore range)
   end
  end
end
