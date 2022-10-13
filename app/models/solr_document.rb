# frozen_string_literal: true
class SolrDocument
  include Blacklight::Solr::Document
  include BlacklightOaiProvider::SolrDocument

  include Blacklight::Gallery::OpenseadragonSolrDocument

  # Adds Hyrax behaviors to the SolrDocument.
  include Hyrax::SolrDocumentBehavior

  # self.unique_key = 'id'
  # Added OAI setting in SolrDocument
  self.timestamp_key = 'system_create_dtsi'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension(Blacklight::Document::Email)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension(Blacklight::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core

  field_semantics.merge!(
    identifier: "id",
    title: "title_tesim",
    creator: "creator_tesim",
    date: "date_created_tesim",
    description: "description_tesim",
    contributor: "contributor_tesim",
    subject: "subject_tesim",
    format: "file_format_tesim",
    language: "language_tesim",
    publisher: "publisher_tesim",
    rights: "rights_statement_tesim",
    source: "source_tesim",
    type: "resource_type_tesim"
  )
  use_extension(Blacklight::Document::DublinCore)

  # Do content negotiation for AF models.

  use_extension( Hydra::ContentNegotiation )

  def degree
    self[Solrizer.solr_name('degree')]
  end

  def department
    self[Solrizer.solr_name('department')]
  end

  def school
    self[Solrizer.solr_name('school')]
  end

  def identifier
    self[Solrizer.solr_name('identifier')]
  end

  def alternate_title
    self[Solrizer.solr_name('alternate_title')]
  end

  def award
    self[Solrizer.solr_name('award')]
  end

  def includes
    self[Solrizer.solr_name('includes')]
  end

  def advisor
    self[Solrizer.solr_name('advisor')]
  end

  def orcid
    self[Solrizer.solr_name('orcid')]
  end

  def committee
    self[Solrizer.solr_name('committee')]
  end

  def defense_date
    self[Solrizer.solr_name('defense_date')]
  end

  def year
    self[Solrizer.solr_name('year')]
  end

  def center
    self[Solrizer.solr_name('center')]
  end

  def funding
    self[Solrizer.solr_name('funding')]
  end

  def sponsor
    self[Solrizer.solr_name('sponsor')]
  end

  def major
    self[Solrizer.solr_name('major')]
  end

  def institute
    self[Solrizer.solr_name('institute')]
  end

  def digitization_date
    self[Solrizer.solr_name('digitization_date')]
  end

  def series
    self[Solrizer.solr_name('series')]
  end

  def event
    self[Solrizer.solr_name('event')]
  end

  def extent
    self[Solrizer.solr_name('extent')]
  end

  def sdg
    self[Solrizer.solr_name('sdg')]
  end

  def note
    self[Solrizer.solr_name('note')]
  end

  def sets
    NewListSet.sets_for(self)
  end
end
