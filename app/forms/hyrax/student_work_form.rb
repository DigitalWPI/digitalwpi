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
  end
end
