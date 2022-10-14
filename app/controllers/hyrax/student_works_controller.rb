# Generated via
#  `rails generate hyrax:work StudentWork`
module Hyrax
  # Generated controller for StudentWork
  class StudentWorksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ControllerUtils
    self.curation_concern_type = ::StudentWork

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::StudentWorkPresenter

    def show
      show_common_works
    end

  end
end
