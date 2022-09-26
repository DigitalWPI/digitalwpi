# Generated via
#  `rails generate hyrax:work GenericWork`
class GenericWork < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = GenericWorkIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :alternate_title, predicate: "http://purl.org/dc/terms/alternative" do |index|
    index.as :stored_searchable
  end

  property :award, predicate: "http://id.loc.gov/ontologies/bibframe/awards" do |index|
    index.as :stored_searchable
  end

  property :includes, predicate: "http://purl.org/dc/terms/hasPart" do |index|
    index.as :stored_searchable
  end

  property :digitization_date, predicate: "http://purl.org/dc/terms/date#digitized", multiple: false do |index|
    index.as :stored_searchable
  end

  property :series, predicate: "http://opaquenamespace.org/ns/seriesName" do |index|
    index.as :stored_searchable
  end

  property :event, predicate: "http://purl.org/dc/terms/coverage" do |index|
    index.as :stored_searchable
  end

  property :year, predicate: "http://purl.org/dc/terms/date", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :extent, predicate: "http://purl.org/dc/terms/extent" do |index|
    index.as :stored_searchable
  end

  property :school, predicate: "http://vivoweb.org/ontology/core#College" do |index|
    index.as :stored_searchable, :facetable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
