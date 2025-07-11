# frozen_string_literal: true
module Hyrax
  class StatsController < ApplicationController
    include Hyrax::SingularSubresourceController
    include Hyrax::Breadcrumbs

    before_action :build_breadcrumbs, :set_document, only: [:work, :file]

    def work
      start_date, end_date = date_range_for_download_statistics.split(',').map(&:to_date)
      @pageviews = Hyrax::Analytics::Results.new(WorkViewStat.where(work_id: @document.id, date: start_date..end_date).map{|stat| [stat.date.to_date, stat.work_views]})
      @downloads = Hyrax::Analytics::Results.new(FileDownloadStat.where(file_id: @document._source["file_set_ids_ssim"], date: start_date..end_date).map{|stat| [stat.date.to_date, stat.downloads]})
    end

    def file
      start_date, end_date = date_range_for_download_statistics.split(',').map(&:to_date)
      @pageviews = Hyrax::Analytics::Results.new(FileViewStat.where(file_id: @document.id, date: start_date..end_date).map{|stat| [stat.date.to_date, stat.views]})
      @downloads = Hyrax::Analytics::Results.new(FileDownloadStat.where(file_id: @document.id, date: start_date..end_date).map{|stat| [stat.date.to_date, stat.downloads]})
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
  end
end