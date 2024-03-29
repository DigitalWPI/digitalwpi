# Generated via
#  `rails generate hyrax:work Etd`
class Etd < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = EtdIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  property :alternate_title, predicate: "http://purl.org/dc/terms/alternative" do |index|
    index.as :stored_searchable
  end

  property :award, predicate: "http://id.loc.gov/ontologies/bibframe/awards" do |index|
    index.as :stored_searchable, :facetable
  end

  property :includes, predicate: "http://purl.org/dc/terms/hasPart" do |index|
    index.as :stored_searchable
  end

  property :advisor, predicate: "http://id.loc.gov/vocabulary/relators/ths" do |index|
    index.as :stored_searchable, :facetable
  end

  property :sponsor, predicate: "http://id.loc.gov/vocabulary/relators/spn" do |index|
    index.as :stored_searchable, :facetable
  end

  property :center, predicate: "http://vivoweb.org/ontology/core#Center" do |index|
    index.as :stored_searchable, :facetable
  end

  property :year, predicate: "http://purl.org/dc/terms/date", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :funding, predicate: "http://vivoweb.org/ontology/core#FundingOrganization" do |index|
    index.as :stored_searchable
  end

  property :institute, predicate: "http://vivoweb.org/ontology/core#Institute" do |index|
    index.as :stored_searchable
  end

  property :orcid, predicate: "http://vivoweb.org/ontology/core#orcidId" do |index|
    index.as :stored_searchable
  end

  property :committee, predicate: "http://id.loc.gov/ontologies/bibframe/contribution" do |index|
    index.as :stored_searchable
  end

  property :degree, predicate: "http://vivoweb.org/ontology/core#AcademicDegree", multiple: false do |index|
    index.as :stored_searchable, :facetable
  end

  property :department, predicate: "http://vivoweb.org/ontology/core#AcademicDepartment" do |index|
    index.as :stored_searchable, :facetable
  end

  property :school, predicate: "http://vivoweb.org/ontology/core#College" do |index|
    index.as :stored_searchable, :facetable
  end

  property :defense_date, predicate: "http://purl.org/dc/terms/dateAccepted", multiple: false do |index|
    index.as :stored_searchable
  end

  property :sdg, predicate: "http://metadata.un.org/sdg/ontology#Goal" do |index|
    index.as :stored_searchable, :facetable
  end

  property :editorial_note, predicate: ::RDF::Vocab::SKOS.editorialNote, multiple: false do |index|
    index.as :displayable
  end

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
