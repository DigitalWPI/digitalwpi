# frozen_string_literal: true

# This is a fix for a bug in Hyrax where under certain circumstances the minter
# stops issuing new IDs, preventing new objects from being created. We encounter
# this sometimes when our ingest process crashes for some reason.
# See https://github.com/samvera/hyrax/issues/3128 for more details.
::Noid::Rails.config.identifier_in_use = lambda do |id|
  ActiveFedora::Base.exists?(id) || ActiveFedora::Base.gone?(id)
end
