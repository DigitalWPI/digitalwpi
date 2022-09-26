# Generated via
#  `rails generate hyrax:work GenericWork`
module Hyrax
  # Generated form for GenericWork
  class GenericWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::GenericWork
    self.terms -= [:alternative_title]
    self.terms += [:resource_type, :alternate_title, :award, :includes]
    self.terms += [:digitization_date, :series, :event, :year]
    self.terms += [:extent, :school]
    self.required_fields -= [:keyword]
  end
end
