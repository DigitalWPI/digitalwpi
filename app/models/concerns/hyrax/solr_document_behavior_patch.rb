# frozen_string_literal: true
require 'hyrax/solr_document_behavior'

module Hyrax
  module SolrDocumentBehavior
    def embargo_visibility
      @visibility ||= if embargo_release_date.present?
                        if first('visibility_during_embargo_ssim').eql?("authenticated")
                          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
                        #elsif first('visibility_during_embargo_ssim').eql?("restricted")
                        #  Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
                        else
                          Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_EMBARGO
                        end
                      elsif lease_expiration_date.present?
                        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_LEASE
                      elsif public?
                        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
                      elsif registered?
                        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
                      else
                        Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
                      end
    end
  end
end
