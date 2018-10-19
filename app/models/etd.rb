# Generated via
#  `rails generate hyrax:work Etd`
class Etd < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = EtdIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :degree, predicate: "http://vivoweb.org/ontology/core#AcademicDegree", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :department, predicate: "http://vivoweb.org/ontology/core#AcademicDepartment" do |index|
    index.as :stored_searchable, :facetable
  end

  property :identifier, predicate: "http://id.loc.gov/ontologies/bibframe/identifiedBy" do |index|
    index.as :stored_searchable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
