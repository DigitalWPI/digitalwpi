# frozen_string_literal: true
module Hyrax
  class StatsController < ApplicationController
    include Hyrax::SingularSubresourceController
    include Hyrax::Breadcrumbs

    before_action :build_breadcrumbs, :set_document, only: [:work, :file]

    def work
      @pageviews = Hyrax::Analytics.daily_events_for_id(@document.id, 'work-view', date_range)
      @downloads = Hyrax::Analytics.daily_events_for_id(@document.id, 'file-set-in-work-download', date_range)
    end

    def file
      @pageviews = Hyrax::Analytics.daily_events_for_id(@document.id, 'file-set-view', date_range)
      @downloads = Hyrax::Analytics.daily_events_for_id(@document.id, 'file-set-download', date_range)
    end

    private

    def set_document
      @document = ::SolrDocument.find(params[:id])
    end

    def add_breadcrumb_for_controller
      add_breadcrumb I18n.t('hyrax.dashboard.my.works'), hyrax.my_works_path
    end

    def add_breadcrumb_for_action
      case action_name
      when 'file'
        add_breadcrumb I18n.t("hyrax.file_set.browse_view"), main_app.hyrax_file_set_path(params["id"])
      when 'work'
        add_breadcrumb @work.to_s, main_app.polymorphic_path(@work)
      end
    end

    def date_range
      start_from = case params[:start_from].to_s
        when '1_month'
          Time.zone.today - 1.month
        when '3_month'
          Time.zone.today - 3.month
        when '6_month'
          Time.zone.today - 6.month
        when '1_year'
          Time.zone.today - 1.year
        else
          Hyrax.config.analytics_start_date
        end
      "#{start_from},#{Time.zone.today}" 
    end
  end
end