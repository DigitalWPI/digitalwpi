# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource StudentWork`
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

    # Use a Valkyrie aware form service to generate Valkyrie::ChangeSet style
    # forms.
    self.work_form_service = Hyrax::FormFactory.new

    def show
      show_common_works
    end

    def edit
      # We do not want to edit previous values of editorial note
      @curation_concern.editorial_note = ''
      super
    end

    def create
      add_date_and_creator_to_note
      super
    end

    def update
      add_date_and_creator_to_note
      super
    end
  end
end
