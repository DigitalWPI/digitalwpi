Rails.configuration.to_prepare do
  Hyrax::Dashboard::NestCollectionsController.class_eval do
    before_action :set_blacklight_config

    private
    def set_blacklight_config
      blacklight_config.add_search_field("something") do |field|
        field.advanced_parse = false
      end
    end
  end
end