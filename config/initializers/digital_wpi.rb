Rails.application.config.application_root_url = 'https://' + ENV['SERVERNAME'].to_s

require 'hyrax/presents_attributes_patch'
require 'hyrax/solr_document_behavior_patch'
