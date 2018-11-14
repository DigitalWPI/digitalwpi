# Generated via
#  `rails generate hyrax:work StudentWork`
module Hyrax
  # Generated controller for StudentWork
  class StudentWorksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::StudentWork

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::StudentWorkPresenter
  end
end
