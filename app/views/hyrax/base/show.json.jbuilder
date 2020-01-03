json.extract! @curation_concern, *[:id] + @curation_concern.class.fields.reject { |f| [:has_model, :head, :tail].include? f }
json.version @curation_concern.etag
