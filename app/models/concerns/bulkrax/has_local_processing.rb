# frozen_string_literal: true

module Bulkrax::HasLocalProcessing
  # This method is called during build_metadata
  # add any special processing here, for example to reset a metadata property
  # to add a custom property from outside of the import data
  def add_local
    parsed_metadata_for_embargo
  end


  def parsed_metadata_for_embargo

    template = ::Hyrax::PermissionTemplate.find_by!(source_id: importerexporter.admin_set_id)

    parsed_metadata["record_visibility"] = embargo_visibility(record["record_visibility"])
    parsed_metadata["visibility"] = embargo_visibility(record["file_visibility"])

    if record["file_visibility"].to_s.downcase == "embargo"
      parsed_metadata["embargo_release_date"] = record["embargo_release_date"]
      parsed_metadata["visibility_during_embargo"] = embargo_visibility(record["visibility_during_embargo"])
      parsed_metadata["visibility_after_embargo"] = embargo_visibility(record["visibility_after_embargo"])
    end
  end

  def embargo_visibility(visibility)
    case visibility.to_s.downcase
    when 'private'
      'restricted'
    when 'wpi'
      'authenticated'
    when 'public'
      'open'
    else
      visibility
    end
  end
end
