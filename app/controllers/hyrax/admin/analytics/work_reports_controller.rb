# frozen_string_literal: true
module Hyrax
  module Admin
    module Analytics
      class WorkReportsController < AnalyticsController
        include Hyrax::BreadcrumbsForWorksAnalytics

        def index
          return unless Hyrax.config.analytics? && Hyrax.config.analytics_provider != 'ga4'

          @accessible_works ||= accessible_works
          @project_centers = project_centers

          if params['center_tesim'].present?
            @accessible_works = @accessible_works.select{|work| work['center_tesim']&.include?(params['center_tesim'])}
          end

          if params['member_of_collection_ids_ssim'].present?
            @accessible_works = @accessible_works.select{|work| work['member_of_collection_ids_ssim']&.include?(params['member_of_collection_ids_ssim'])}
          end

          @accessible_file_sets ||= accessible_file_sets
          @works_count = @accessible_works.count
          @top_works = paginate(top_works_list, rows: 10)
          @top_file_set_downloads = paginate(top_files_list, rows: 10)

          if current_user.ability.admin?
            @pageviews = Hyrax::Analytics::Results.new(WorkViewStat.all.map{|stat| [stat.date, stat.work_views]})
            @downloads = Hyrax::Analytics::Results.new(FileDownloadStat.all.map{|stat| [stat.date, stat.downloads]})
          end

          respond_to do |format|
            format.html
            format.csv { export_data }
          end
        end

        def show
          @pageviews =  Hyrax::Analytics::Results.new(WorkViewStat.where(work_id: @document.id).map{|stat| [stat.date, stat.work_views]})
          @uniques = Hyrax::Analytics.unique_visitors_for_id(@document.id)
          @file_download_stats = FileDownloadStat.where(file_id: @document._source["file_set_ids_ssim"])
          @downloads = Hyrax::Analytics::Results.new(@file_download_stats.map{|stat| [stat.date, stat.downloads]})
          @files = paginate(@document._source["file_set_ids_ssim"], rows: 5)
          respond_to do |format|
            format.html
            format.csv { export_data }
          end
        end

        private

        def accessible_works
          models = Hyrax.config.curation_concerns.map { |m| "\"#{m}\"" }
          if current_user.ability.admin?
            ActiveFedora::SolrService.query("has_model_ssim:(#{models.join(' OR ')})",
              fl: 'title_tesim, id, member_of_collection_ids_ssim, center_tesim',
              rows: 50_000)
          else
            ActiveFedora::SolrService.query(
              "edit_access_person_ssim:#{current_user} AND has_model_ssim:(#{models.join(' OR ')})",
              fl: 'title_tesim, id, member_of_collection_ids_ssim, center_tesim',
              rows: 50_000
            )
          end
        end

        def accessible_file_sets
          if current_user.ability.admin?
            ActiveFedora::SolrService.query(
              "has_model_ssim:FileSet",
              fl: 'title_tesim, id',
              rows: 50_000
            )
          else
            ActiveFedora::SolrService.query(
              "edit_access_person_ssim:#{current_user} AND has_model_ssim:FileSet",
              fl: 'title_tesim, id',
              rows: 50_000
            )
          end
        end

        def top_analytics_works
          start_date, end_date = date_range.split(',').map(&:to_date)
          @top_analytics_works ||= WorkViewStat.where(date: start_date..end_date).group(:work_id)
          .select(:work_id, 'SUM(work_views) AS total_views')
          .order('total_views DESC')
        end

        def top_analytics_downloads(work_id)
          document = ::SolrDocument.find(work_id)
          start_date, end_date = date_range.split(',').map(&:to_date)
          FileDownloadStat.where(date: start_date..end_date, file_id: document._source["file_set_ids_ssim"])
        end

        def top_analytics_file_sets
          start_date, end_date = date_range.split(',').map(&:to_date)
          @top_analytics_file_sets ||= FileDownloadStat.where(date: start_date..end_date).group(:file_id)
          .select(:file_id, 'SUM(downloads) AS total_downloads')
          .order('total_downloads DESC')
        end

        def top_works_list
          list = []
          top_analytics_works
          @accessible_works.each do |doc|
            views_match = @top_analytics_works.detect { |stat| stat.work_id == doc["id"] }
            total_views = views_match ? views_match.total_views : 0
            downloads_match = top_analytics_downloads( doc["id"])
            @download_count = downloads_match ? downloads_match.sum(:downloads) : 0
            list.push([doc["id"], doc["title_tesim"].join(''), total_views, @download_count, doc["member_of_collections"]])
          end
          list.sort_by { |l| -l[2] }
        end

        def top_files_list
          list = []
          top_analytics_file_sets
          @accessible_file_sets.each do |doc|
            downloads_match = @top_analytics_file_sets.detect { |stat| stat.file_id == doc["id"] }
            @download_count = downloads_match ? downloads_match.total_downloads : 0
            list.push([doc["id"], doc["title_tesim"].join(''), @download_count]) if doc["title_tesim"].present?
          end
          list.sort_by { |l| -l[2] }
        end

        def export_data
          data = top_works_list
          csv_row = CSV.generate do |csv|
            csv << ["Name", "ID", "Work Page Views", "Total Downloads of File Sets In Work", "Collections"]
            data.each do |d|
              csv << [d[0], d[1], d[2], d[3], d[4]]
            end
          end
          send_data csv_row, filename: "#{params[:start_date]}-#{params[:end_date]}-works.csv"
        end

        def project_centers
          @accessible_works.map{|work| work['center_tesim']}.compact.flatten.uniq
        end
      end
    end
  end
end
