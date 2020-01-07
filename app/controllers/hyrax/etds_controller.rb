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
      @user_collections = user_collections

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
        wants.json do
          # load and authorize @curation_concern manually because it's skipped for html
          @curation_concern = _curation_concern_type.find(params[:id]) unless curation_concern
          authorize! :show, @curation_concern
          render :show, status: :ok
        end
        additional_response_formats(wants)
        wants.ttl do
          render body: presenter.export_as_ttl, content_type: 'text/turtle'
        end
        wants.jsonld do
          render body: presenter.export_as_jsonld, content_type: 'application/ld+json'
        end
        wants.nt do
          render body: presenter.export_as_nt, content_type: 'application/n-triples'
        end
        wants.csv do
          @curation_concern = _curation_concern_type.find(params[:id]) unless curation_concern
          authorize! :show, @curation_concern
          in_json = JSON.parse(render_to_string :show)
          render body: presenter.export_as_csv(in_json), content_type: 'text/csv'
        end
      end

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
