# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior


  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models. 

  use_extension( Hydra::ContentNegotiation )

  def degree
    self["degree_tesim"]
  end

  def department
    self["department_tesim"]
  end

  def school
    self["school_tesim"]
  end

  def identifier
    self["identifier_tesim"]
  end

  def alternate_title
    self["alternate_title_tesim"]
  end

  def award
    self["award_tesim"]
  end

  def includes
    self["includes_tesim"]
  end

  def advisor
    self["advisor_tesim"]
  end

  def orcid
    self["orcid_tesim"]
  end

  def committee
    self["committee_tesim"]
  end

  def defense_date
    self["defense_date_tesim"]
  end

  def year
    self["year_tesim"]
  end

  def center
    self["center_tesim"]
  end

  def funding
    self["funding_tesim"]
  end

  def sponsor
    self["sponsor_tesim"]
  end

  def major
    self["major_tesim"]
  end

  def institute
    self["institute_tesim"]
  end

  def digitization_date
    self["digitization_date_tesim"]
  end

  def series
    self["series_tesim"]
  end

  def event
    self["event_tesim"]
  end

  def extent
    self["extent_tesim"]
  end

  def sdg
    self["sdg_tesim"]
  end

  def note
    self["note_tesim"]
  end

  def sets
    NewListSet.sets_for(self)
  end

  def editorial_note
    self["editorial_note_tesim"]
  end

  def citation
    self["citation_tesim"]
  end
end
