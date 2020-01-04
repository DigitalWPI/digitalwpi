json.extract! @curation_concern, *[:id] + @curation_concern.class.fields.reject { |f| [:has_model, :head, :tail].include? f }
json.version @curation_concern.etag
json.permalink Rails.application.config.application_root_url + main_app.common_object_path(locale: nil)
