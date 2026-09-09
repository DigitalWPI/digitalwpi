class AdvancedController < BlacklightAdvancedSearch::AdvancedController
  copy_blacklight_config_from(CatalogController)
  before_action :change_advance_blacklight_config

  private

  def change_advance_blacklight_config
    blacklight_config.facet_fields.each do |key, val|
      blacklight_config.facet_fields[key].limit = -1
    end
  end
end