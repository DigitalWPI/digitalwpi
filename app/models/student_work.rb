# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource StudentWork`
class StudentWork < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:student_work)
end
