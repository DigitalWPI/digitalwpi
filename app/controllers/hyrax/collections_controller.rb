# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/hyrax/collections_controller.rb')
module Hyrax
  class CollectionsController < ApplicationController
    def show
      presenter
      query_collection_members
      @permalinks_presenter = PermalinksPresenter.new(collection_path(locale: nil))
    end
  end
end
