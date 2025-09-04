# frozen_string_literal: true
module Hyrax
  module Admin
    module Analytics
      class WorkReportsController < AnalyticsController
        include Hyrax::BreadcrumbsForWorksAnalytics

        def index
          return unless Hyrax.config.analytics? && Hyrax.config.analytics_provider != 'ga4'

          @start_date, @end_date = date_range.split(',').map(&:to_date)
          @accessible_works = accessible_works
          @accessible_file_sets = accessible_file_sets

          work_views = precompute_work_views
          file_downloads = precompute_file_downloads
          work_file_downloads = precompute_work_downloads(file_downloads)
          
          @works_count = work_views.size
          
          respond_to do |format|
            format.html do
              @project_centers = project_centers
              @collection_filter = collection_filter
              @top_works = paginate(build_top_works_list(work_views, work_file_downloads), rows: 10)
              @top_file_set_downloads = paginate(build_top_files_list(file_downloads), rows: 10)
    
              if current_user.ability.admin?
                @pageviews = Hyrax::Analytics::Results.new(work_stats.pluck(:date, :work_views))
                @downloads = Hyrax::Analytics::Results.new(file_stats.pluck(:date, :downloads))
              end
            end
            format.csv { export_data(work_views, work_file_downloads) }
          end
        end

        def show
          @pageviews =  Hyrax::Analytics::Results.new(WorkViewStat.where(work_id: @document.id).where("work_views > 0").map{|stat| [stat.date, stat.work_views]})
          @uniques = Hyrax::Analytics.unique_visitors_for_id(@document.id)
          @file_download_stats = FileDownloadStat.where(file_id: @document._source["file_set_ids_ssim"]).where("downloads > 0")
          @downloads = Hyrax::Analytics::Results.new(@file_download_stats.map{|stat| [stat.date, stat.downloads]})
          @files = paginate(@document._source["file_set_ids_ssim"], rows: 5)
          respond_to do |format|
            format.html
            format.csv { export_work_data }
          end
        end

        private

        def accessible_works
          models = Hyrax.config.curation_concerns.map { |m| "\"#{m}\"" }
          query = "has_model_ssim:(#{models.join(' OR ')})"
          
          if params['center_tesim'].present?
            query += " AND center_tesim:\"#{params['center_tesim']}\""
          end
          
          if params['member_of_collection_ids_ssim'].present?
            query += " AND member_of_collection_ids_ssim:#{params['member_of_collection_ids_ssim']}"
          end

          fl = 'id, title_tesim, member_of_collection_ids_ssim, file_set_ids_ssim, center_tesim'
          if current_user.ability.admin?
            ActiveFedora::SolrService.query(query, fl: fl, rows: 50_000)
          else
            ActiveFedora::SolrService.query(
              "#{query} AND edit_access_person_ssim:#{current_user}",
              fl: fl,
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

        def precompute_work_views
          work_stats.group_by(&:work_id).transform_values do |rows|
            rows.sum(&:work_views)
          end
        end

        def precompute_file_downloads
          file_stats.group_by(&:file_id).transform_values do |rows|
            rows.sum(&:downloads)
          end
        end

        def precompute_work_downloads(file_downloads)
          # Build a hash mapping work_id to total downloads for its file sets, using only file_set_ids that have downloads
          file_set_ids_with_downloads = file_downloads.keys.to_set
          Hash.new(0).tap do |work_downloads|
            @accessible_works.each do |work|
              ids = Array(work['file_set_ids_ssim']) & file_set_ids_with_downloads.to_a
              next if ids.empty?
              sum = ids.sum { |fid| file_downloads[fid] || 0 }
              work_downloads[work['id']] = sum
            end
          end
        end

        def build_top_works_list(work_views, work_downloads)
          # Use a single pass and avoid filter_map for better memory efficiency
          result = []
          @accessible_works.each do |work|
            id = work['id']
            views = work_views[id]
            next unless views
            result << [
              id,
              work['title_tesim']&.join('') || '',
              views,
              work_downloads[id] || 0,
              work['member_of_collection_ids_ssim']
            ]
          end
          result.sort_by! { |work| -work[2] }
          result
        end

        def build_top_files_list(file_downloads)
          file_lookup = @accessible_file_sets.index_by { |f| f['id'] }
          
          file_downloads.filter_map do |id, count|
            file = file_lookup[id]
            next unless file
            [
              id,
              file['title_tesim']&.join('') || '',
              count
            ]
          end.sort_by { |file| -file[2] }
        end

        def export_data(work_views, work_downloads)
          data = build_top_works_list(work_views, work_downloads)
          csv = CSV.generate do |rows|
            rows << ['Name', 'ID', 'Work Page Views', 'Total Downloads of File Sets In Work', 'Collections']
            data.each do |row|
              rows << [row[1], row[0], row[2], row[3], Array(row[4]).join('; ')]
            end
          end
          send_data csv, filename: "#{params[:start_date]}-#{params[:end_date]}-works.csv"
        end

        def export_work_data
          work = @document
          file_set_ids = work._source["file_set_ids_ssim"] || []
          file_sets = ActiveFedora::SolrService.query("{!terms f=id}#{file_set_ids.join(',')}", fl: 'id, title_tesim', rows: file_set_ids.size)
          
          file_downloads = FileDownloadStat.where(file_id: file_set_ids)
                                          .group(:file_id)
                                          .sum(:downloads)
          
          csv = CSV.generate do |rows|
            rows << ['File Name', 'File ID', 'Downloads']
            file_sets.each do |file|
              rows << [file['title_tesim']&.join(''), file['id'], file_downloads[file['id']] || 0]
            end
          end
          
          send_data csv, filename: "work-#{work.id}-file-downloads.csv"
        end

        def project_centers
          @accessible_works.flat_map { |w| w['center_tesim'] }.compact.uniq
        end

        def work_stats
          @work_stats ||= WorkViewStat.where(date: @start_date..@end_date).where("work_views > 0")
        end

        def file_stats
          @file_stats ||= FileDownloadStat.where(date: @start_date..@end_date).where("downloads > 0")
        end

        def collection_filter
          @collection_filter = Collection.where(id: @accessible_works.flat_map { |w| w['member_of_collection_ids_ssim'] }.compact.uniq).map { |c| [c.id, c.title[0]] }.to_h
        end
      end
    end
  end
end
