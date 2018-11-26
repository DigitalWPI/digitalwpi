# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.terms += [:degree, :department, :alternate_title, :award, :includes]
    self.terms += [:advisor, :orcid, :committee, :defense_date, :year, :center]
    self.terms += [:funding, :sponsor, :institute, :school]
    self.required_fields -= [:keyword]
  end
end
