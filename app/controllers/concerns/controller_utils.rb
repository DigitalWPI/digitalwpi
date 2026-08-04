module ControllerUtils
  extend ActiveSupport::Concern

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

    permalink_message = "Permanent link to this page"
    @permalinks_presenter = PermalinksPresenter.new(main_app.common_object_path(locale: nil), permalink_message)
  end

  private

  def add_date_and_creator_to_note
    model = _curation_concern_type.model_name.param_key
    notes = normalize_editorial_notes(@curation_concern.editorial_note)

    if params[model].include?('editorial_note') && params[model]['editorial_note'].present?
      notes << {
        'note' => params[model]['editorial_note'],
        'created' => Time.current.iso8601,
        'user_id' => current_user&.email,
        'user_name' => current_user&.name
      }
    end

    params[model]['editorial_note'] = notes.to_json if notes.present?
  end

  def normalize_editorial_notes(value)
    return [] if value.blank?

    parsed_value = case value
                   when String
                     JSON.parse(value)
                   when Array
                     value
                   when Hash
                     [value]
                   else
                     []
                   end

    parsed_value = [parsed_value] unless parsed_value.is_a?(Array)
    parsed_value.map { |note| note.is_a?(Hash) ? note : { 'note' => note.to_s } }
  rescue JSON::ParserError
    []
  end

end
