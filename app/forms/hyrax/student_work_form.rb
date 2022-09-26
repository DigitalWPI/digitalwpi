# Generated via
#  `rails generate hyrax:work StudentWork`
module Hyrax
  # Generated form for StudentWork
  class StudentWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::StudentWork
    self.terms += [:resource_type, :award, :includes]
    self.terms += [:advisor, :sponsor, :center, :year]
    self.terms += [:funding, :institute, :sdg, :school, :major]
    self.required_fields -= [:keyword]
  end
end
