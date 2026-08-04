# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource Etd`
class Etd < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:etd)
  include CommonQuery
end
