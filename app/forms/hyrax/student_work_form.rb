# Generated via
#  `rails generate hyrax:work StudentWork`
module Hyrax
  # Generated form for StudentWork
  class StudentWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::StudentWork
    self.terms -= [:alternative_title]
    self.terms += [:resource_type, :award, :includes, :alternate_title]
    self.terms += [:advisor, :sponsor, :center, :year]
    self.terms += [:funding, :institute, :sdg, :school, :major]
    self.terms += [:note]
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
      :advisor,
      :sponsor,
      :center,
      :year,
      :funding,
      :institute,
      :sdg,
      :school,
      :major,
      :note,
      :editorial_note]
    end
  
    def secondry_terms
      []
    end
  end
end
