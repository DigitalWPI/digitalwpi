# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Etd`
module Hyrax
  # Generated controller for Etd
  class EtdsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Etd

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::EtdPresenter

    def show
      super
      permalink_message = "Permanent link to this page"
      @permalinks_presenter = PermalinksPresenter.new(main_app.common_object_path(locale: nil), permalink_message)
    end

    private

      def additional_response_formats(format)
        format.endnote do
          send_data(presenter.solr_document.export_as_endnote,
                    type: "application/x-endnote-refer",
                    filename: presenter.solr_document.endnote_filename)
        end
        format.ris do
          send_data(presenter.solr_document.export_as_ris,
                    type: "application/x-research-info-systems",
                    filename: presenter.solr_document.ris_filename)
        end
        format.bib do
          send_data(presenter.solr_document.export_as_bib,
                    type: "application/x-bibtex",
                    filename: presenter.solr_document.bib_filename)
        end
      end
  end
end
