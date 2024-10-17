# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  # Generated form for GenericWork
  class GenericWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::GenericWork
    self.terms -= [:alternative_title]
    self.terms += [:resource_type, :award, :includes, :alternate_title]
    self.terms += [:digitization_date, :series, :event, :year]
    self.terms += [:extent, :school]
    self.terms += [:citation]
    self.terms += [:editorial_note]
    self.required_fields -= [:keyword]

    def primary_terms
      [:title,
      :creator,
      :rights_statement,
      :contributor,
      :description,
      :abstract,
      :keyword,
      :license,
      :access_right,
      :rights_notes,
      :publisher,
      :date_created,
      :subject,
      :language,
      :identifier,
      :based_near,
      :related_url,
      :source,
      :resource_type,
      :award,
      :includes,
      :alternate_title,
      :digitization_date,
      :series,
      :event,
      :year,
      :extent,
      :school,
      :citation,
      :editorial_note]
    end

    def secondry_terms
      []
    end
    
  end
end
