# frozen_string_literal: true
module Hyrax
  class StatsController < ApplicationController
    include Hyrax::SingularSubresourceController
    include Hyrax::Breadcrumbs

    before_action :build_breadcrumbs, :set_document, only: [:work, :file]

    def work
      @pageviews = Hyrax::Analytics::Results.new(work_view_stats)
      @downloads = Hyrax::Analytics::Results.new(work_download_stats)
      @selected_range = selected_range
      @default_download_start_date = default_download_start_date
    end

    def file
      @pageviews = Hyrax::Analytics::Results.new(file_view_stats)
      @downloads = Hyrax::Analytics::Results.new(file_download_stats)
      @selected_range = selected_range
      @default_download_start_date = default_download_start_date
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

    def date_range_for_view_statistics
      "#{params[:start_date] || Hyrax.config.analytics_start_date},#{params[:end_date] || Date.today}" 
    end

    def default_download_start_date
      ENV['DOWNLOAD_STATS_START_DATE'].to_date || Hyrax.config.analytics_start_date.to_date
    end

    def start_date_for_download_stats
      default_start_date = ENV['DOWNLOAD_STATS_START_DATE'].to_date || Hyrax.config.analytics_start_date.to_date
      start_date = params[:start_date]&.to_date
      start_date.present? && start_date >= default_start_date ? start_date.to_date : default_start_date.to_date
    end

    def end_date_for_download_stats
      default_start_date = ENV['DOWNLOAD_STATS_START_DATE'].to_date || Hyrax.config.analytics_start_date.to_date
      end_date = params[:end_date]&.to_date
      end_date.present? && end_date >= default_start_date ? end_date.to_date : Date.today
    end

    def file_view_stats
      start_date, end_date = date_range_for_view_statistics.split(',').map(&:to_date)
      data = {}
      FileViewStat.where(file_id: @document.id, date: start_date..end_date).map{|stat| data[stat.date.to_date] = stat.views}
      (start_date..end_date).map { |date| [date, data[date] || 0] }
    end

    def work_view_stats
      start_date, end_date = date_range_for_view_statistics.split(',').map(&:to_date)
      data = {}
      WorkViewStat.where(work_id: @document.id, date: start_date..end_date).map{|stat| data[stat.date.to_date] = stat.work_views}
      (start_date..end_date).map { |date| [date, data[date] || 0] }
    end

    def work_download_stats
      default_start_date = ENV['DOWNLOAD_STATS_START_DATE'].to_date || Hyrax.config.analytics_start_date.to_date
      start_date = start_date_for_download_stats
      end_date = end_date_for_download_stats
      download_stats = FileDownloadStat.where(file_id: @document._source["file_set_ids_ssim"], date: start_date..end_date)
      data = {}
      return data if params[:end_date]&.to_date.present? && params[:end_date]&.to_date < default_start_date
      download_stats.group_by { |stat| stat.date.to_date }.map { |date, records| data[date] = records.sum(&:downloads) }
      (start_date..end_date).map { |date| [date, data[date] || 0] }
    end

    def file_download_stats
      default_start_date = ENV['DOWNLOAD_STATS_START_DATE'].to_date || Hyrax.config.analytics_start_date.to_date
      start_date = start_date_for_download_stats
      end_date = end_date_for_download_stats
      data = {}
      return data if params[:end_date]&.to_date.present? && params[:end_date]&.to_date < default_start_date
      FileDownloadStat.where(file_id: @document.id, date: start_date..end_date).map{|stat| data[stat.date.to_date] = stat.downloads}
      (start_date..end_date).map { |date| [date, data[date] || 0] }
    end

    def selected_range
      label = "Custom range"
      default_start_date = Hyrax.config.analytics_start_date
      st_dt, end_dt = date_range_for_view_statistics
      if st_dt == default_start_date and end_dt == Time.zone.today
        label = "All Time"
      elsif st_dt == (Date.today - 1.month).to_s and end_dt == Time.zone.today
        label = "Last month"
      elsif st_dt == (Date.today - 3.month).to_s and end_dt == Time.zone.today
        label = "Last 3 months"
      elsif st_dt == (Date.today - 6.month).to_s and end_dt == Time.zone.today
        label = "Last 6 months"
      elsif st_dt == (Date.today - 1.year).to_s and end_dt == Time.zone.today
        label = "Last 1 year"
      else
        label = "Custom range"
      end
      label
    end
  end
end