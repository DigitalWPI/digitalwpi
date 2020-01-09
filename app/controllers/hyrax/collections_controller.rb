# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/hyrax/collections_controller.rb')
module Hyrax
  class CollectionsController < ApplicationController
  
    copy_blacklight_config_from(CatalogController)

    before_action :collection_facet_update, :only => [:show, :public_show, :facet]

    def collection_facet_update
      blacklight_config.facet_fields['member_of_collection_ids_ssim'].show = false
      blacklight_config.facet_fields['member_of_collection_ids_ssim'].if = false
    end
  
    def show
      presenter
      query_collection_members
      @permalinks_presenter = PermalinksPresenter.new(collection_path(locale: nil))
    end
  end
end
