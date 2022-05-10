# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated form for Etd
  class EtdForm < Hyrax::Forms::WorkForm
    self.model_class = ::Etd
    self.terms += [:resource_type, :degree, :department, :alternate_title]
    self.terms += [:advisor, :orcid, :committee, :defense_date, :year, :center]
    self.terms += [:funding, :sponsor, :institute, :sdg, :school, :award, :includes]
    self.required_fields -= [:keyword]
  end
end
