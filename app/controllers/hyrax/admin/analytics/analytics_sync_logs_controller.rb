# app/controllers/admin/analytics_syncs_controller.rb
module Hyrax
  module Admin
    module Analytics
      class AnalyticsSyncLogsController < ApplicationController

        def sync
          sync_type = params[:sync_type] # "view" or "download"

          ::MatomoAnalyticsSyncJob.perform_later

          redirect_back fallback_location: hyrax.dashboard_path, notice: "Sync started. It will complete in the background."
        end
      end
    end
  end
end
