Rails.configuration.to_prepare do
  Hyrax::PresentsAttributes.module_eval do
    def embargo_permission_badge
      permission_badge_class.new(solr_document.embargo_visibility).render
    end
  end
end