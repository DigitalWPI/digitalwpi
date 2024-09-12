require 'hyrax/presents_attributes'

module Hyrax
  module PresentsAttributes
    def embargo_permission_badge
      permission_badge_class.new(solr_document.embargo_visibility).render
    end
  end
end