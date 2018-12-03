# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  class GenericWorkPresenter < Hyrax::WorkShowPresenter
    delegate :alternate_title, to: :solr_document
    delegate :award, to: :solr_document
    delegate :includes, to: :solr_document
    delegate :digitization_date, to: :solr_document
    delegate :series, to: :solr_document
    delegate :event, to: :solr_document
    delegate :year, to: :solr_document
    delegate :extent, to: :solr_document
    delegate :school, to: :solr_document
  end
end
