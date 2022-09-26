module ControllerUtils
  def additional_response_formats(format)
    format.endnote do
      send_data(presenter.solr_document.export_as_endnote,
                type: Mime[:endnote],
                filename: presenter.solr_document.endnote_filename)
    end
    format.ris do
      send_data(presenter.solr_document.export_as_ris,
                type: Mime[:ris],
                filename: presenter.solr_document.ris_filename)
    end
    format.bib do
      send_data(presenter.solr_document.export_as_bib,
                type: Mime[:bib],
                filename: presenter.solr_document.bib_filename)
    end
  end

  def show_common_works
    @user_collections = user_collections

    respond_to do |wants|
      wants.html { presenter && parent_presenter }
      wants.json do
        # load @curation_concern manually because it's skipped for html
        @curation_concern = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: params[:id])
        curation_concern # This is here for authorization checks (we could add authorize! but let's use the same method for CanCanCan)
        render :show, status: :ok
      end
      additional_response_formats(wants)
      wants.ttl { render body: presenter.export_as_ttl, mime_type: Mime[:ttl] }
      wants.jsonld { render body: presenter.export_as_jsonld, mime_type: Mime[:jsonld] }
      wants.nt { render body: presenter.export_as_nt, mime_type: Mime[:nt] }
      wants.csv do
        @curation_concern = _curation_concern_type.find(params[:id]) unless curation_concern
        curation_concern
        in_json = JSON.parse(render_to_string :show)
        render body: presenter.export_as_csv(in_json), content_type: Mime[:csv]
      end
    end

    # KTODO undefined common_object_path
    # @permalinks_presenter = PermalinksPresenter.new(main_app.common_object_path(locale: nil),
    #                                                 "Permanent link to this page")
  end

end