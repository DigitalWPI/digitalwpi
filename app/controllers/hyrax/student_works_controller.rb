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

    def edit
      # We do not want to edit previous values of editorial note
      @curation_concern.editorial_note = ''
      super
    end

    def create
      add_date_and_creator_to_note('student_work')
      super
    end

    def update
      add_date_and_creator_to_note('student_work')
      super
    end

  end
end
