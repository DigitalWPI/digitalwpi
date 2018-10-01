# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  class EtdPresenter < Hyrax::WorkShowPresenter
    delegate :degree, to: :solr_document
    delegate :department, to: :solr_document
  end
end
