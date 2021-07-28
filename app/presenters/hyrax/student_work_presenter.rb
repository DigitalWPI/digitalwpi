# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work StudentWork`
module Hyrax
  class StudentWorkPresenter < Hyrax::WorkShowPresenter
    delegate :note, to: :solr_document
    delegate :advisor, to: :solr_document
    delegate :alternate_title, to: :solr_document
    delegate :award, to: :solr_document
    delegate :center, to: :solr_document
    delegate :committee, to: :solr_document
    delegate :defense_date, to: :solr_document
    delegate :degree, to: :solr_document
    delegate :department, to: :solr_document
    delegate :digitization_date, to: :solr_document
    delegate :event, to: :solr_document
    delegate :extent, to: :solr_document
    delegate :funding, to: :solr_document
    delegate :includes, to: :solr_document
    delegate :institute, to: :solr_document
    delegate :sdg, to: :solr_document
    delegate :major, to: :solr_document
    delegate :orcid, to: :solr_document
    delegate :school, to: :solr_document
    delegate :series, to: :solr_document
    delegate :sponsor, to: :solr_document
    delegate :year, to: :solr_document
  end
end
