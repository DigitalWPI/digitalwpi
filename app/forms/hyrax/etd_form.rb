# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.terms -= [:alternative_title]
    self.terms += [:resource_type, :degree, :department, :alternate_title]
    self.terms += [:advisor, :orcid, :committee, :defense_date, :year, :center]
    self.terms += [:funding, :sponsor, :institute, :school, :award, :includes]
    self.required_fields -= [:keyword]
  end
end
