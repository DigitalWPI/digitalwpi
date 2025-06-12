# frozen_string_literal: true
module Hyrax
  class StatsController < ApplicationController
    include Hyrax::SingularSubresourceController
    include Hyrax::Breadcrumbs

    before_action :build_breadcrumbs, :set_document, only: [:work, :file]

    def work
      @pageviews = Hyrax::Analytics.daily_events_for_url(page_url, split_into_year_ranges, get_local_results)
      @downloads = Hyrax::Analytics.daily_events_for_id(@document.id, 'file-set-in-work-download', date_range_for_download_statistics)
    end

    def file
      @pageviews = Hyrax::Analytics.daily_events_for_url(page_url, split_into_year_ranges, get_local_results)
      @downloads = Hyrax::Analytics.daily_events_for_id(@document.id, 'file-set-download', date_range_for_download_statistics)
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

    def date_range_for_download_statistics
      "#{params[:start_date] || Hyrax.config.analytics_start_date},#{params[:end_date] || Date.today}" 
    end

    def page_url
      if action_name == 'file'
        main_app.hyrax_file_set_path(@file.id)
      else
        "concern/#{@work.class.name.underscore.pluralize}/#{@work.id}"
      end
    end

    def split_into_year_ranges
      start_date = Date.parse(params[:start_date] || Hyrax.config.analytics_start_date.to_s)
      end_date = Date.parse(params[:end_date] || Date.today.to_s)

      ranges = []
      current_start = start_date

      while current_start <= end_date
        current_end = [current_start.next_year - 1, end_date].min
        ranges << "#{current_start},#{current_end}"
        current_start = current_end + 1
      end

      ranges
    end

    def get_local_results
      start_date, end_date = date_range_for_download_statistics.split(',').map { |d| d.to_time.beginning_of_day }
      results = if action_name == 'file'
        FileViewStat.where(file_id: @file.id, date: start_date..end_date)&.order(date: :asc)&.map { |stat| [stat.date.to_date, stat.views] }
      else
        WorkViewStat.where(work_id: @work.id, date: start_date..end_date)&.order(date: :asc)&.map { |stat| [stat.date.to_date, stat.work_views] }
      end
      results || []
    end
  end
end