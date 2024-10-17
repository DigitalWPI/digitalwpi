# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.terms -= [:alternative_title]
    self.terms += [:resource_type, :degree, :department, :alternate_title]
    self.terms += [:advisor, :orcid, :committee, :defense_date, :year, :center]
    self.terms += [:funding, :sponsor, :institute, :sdg, :school, :award, :includes]
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
      :degree,
      :department,
      :alternate_title,
      :advisor,
      :orcid,
      :committee,
      :defense_date,
      :year,
      :center,
      :funding,
      :sponsor,
      :institute,
      :sdg,
      :school,
      :award,
      :includes,
      :editorial_note]
    end
  
    def secondry_terms
      []
    end
  end
end
