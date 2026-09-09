# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource Etd`
class EtdIndexer < Hyrax::Indexers::PcdmObjectIndexer(Etd)
  include Hyrax::Indexer(:basic_metadata)
  include Hyrax::Indexer(:etd)
  include IndexerHelper

  def to_solr
    super.tap do |index_document|
      index_document['license_sim'] = resource.license
      index_document['all_metadata_tesim'] = all_metadata_values
      index_document['title_ansort'] = resource.title.first
      dt = nil
      dt = parse_date(resource.date_created&.first) if resource.date_created&.first
      index_document['date_created_dtsi'] = dt.strftime("%Y-%m-%dT%H:%M:%SZ") if dt
      if resource.year
        index_document['year_sim'] = resource.year.strip[0,4]
      elsif dt
        index_document['year_sim'] = dt.year
      end
      index_document['creator_lsim'] = resource.creator
      index_document['advisor_lsim'] = resource.advisor
    end
  end
end
