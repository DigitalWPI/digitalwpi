# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/hyrax/file_sets_controller.rb')

module Hyrax
  class FileSetsController < ApplicationController
    def show
      respond_to do |wants|
        wants.html { presenter }
        wants.json { presenter }
        additional_response_formats(wants)
      end
      permalink_message = "Permanent link to this page"
      @permalinks_presenter = PermalinksPresenter.new(main_app.common_object_path(locale: nil), permalink_message)
    end
  end
end
