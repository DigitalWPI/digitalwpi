# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work StudentWork`
module Hyrax
  # Generated form for StudentWork
  class StudentWorkForm < Hyrax::Forms::WorkForm
    self.model_class = ::StudentWork
    self.terms += [:resource_type, :alternate_title, :award, :includes]
    self.terms += [:advisor, :sponsor, :center, :year]
    self.terms += [:funding, :institute, :school, :major]
    self.required_fields -= [:keyword]
    # self.required_fields += [:member_of_collection_ids]
  end
end
