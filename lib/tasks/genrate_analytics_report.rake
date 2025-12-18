require 'json'

namespace :wpi do
  desc 'Generate analytics report Use: rake wpi:generate_analytics_report[start_date,end_date,member_of_collection_id,project_center]'
  desc "Example: rake wpi:generate_analytics_report['2023-01-01','2023-12-31','js956f926','Project Center Name']"

  task :generate_analytics_report, [:start_date, :end_date, :member_of_collection_id, :project_center] => :environment do |task, args|
    @start_date = args[:start_date].present? ? args[:start_date].to_date : Hyrax.config.analytics_start_date.to_date
    @end_date = args[:end_date].present? ? args[:end_date].to_date : Date.today
    @center_tesim = args[:project_center]
    @member_of_collection_ids_ssim = args[:member_of_collection_id]

    @accessible_works = accessible_works
    work_views = precompute_work_views
    file_downloads = precompute_file_downloads
    work_file_downloads = precompute_work_downloads(file_downloads)

    data = build_top_works_list(work_views, work_file_downloads)
    csv = CSV.open(Rails.root.join('tmp', "analytics_report_#{@start_date}_#{@end_date}.csv"), "wb") do |rows|
      rows << ['Title', 'Digital WPI URL', 'Work Page Views', 'Total Downloads',
               'Collection Name', 'Creator(s)', 'Advisor(s)', 'Resource type',
               'Date created', 'Major', 'Unit', 'Project Center', 'Sponsor', 'UN SDG']
      data.each do |row|
        rows << [row[1], row[0], row[2], row[3], Array(row[4]).join('; ')]
      end
    end    
  end

  def build_top_works_list(work_views, work_downloads)
    result = []
    @accessible_works.each do |work|
      id = work['id']
      views = work_views[id]
      next unless views
      result << [
        work['title_tesim']&.join('') || '',
        PermalinksPresenter.new("/show/#{id}").url,
        views,
        work_downloads[id] || 0,
        get_collection_name(work['member_of_collection_ids_ssim'])&.join('; ') || '',
        work['creator_tesim']&.join('; ') || '',
        work['advisor_tesim']&.join('; ') || '',
        work['resource_type_tesim']&.join('; ') || '',
        work['date_created_tesim']&.join('; ') || '',
        work['major_tesim']&.join('; ') || '',
        work['department_tesim']&.join('; ') || '',
        work['center_tesim']&.join('; ') || '',
        work['sponsor_tesin']&.join('; ') || '',
        work['sdg_tesim']&.join('; ') || ''
      ]
    end
    result.sort_by! { |work| -work[2] }
    result
  end

  def work_stats
    @work_stats ||= WorkViewStat.where(date: @start_date..@end_date).where("work_views > 0")
  end

  def file_stats
    @file_stats ||= FileDownloadStat.where(date: @start_date..@end_date).where("downloads > 0")
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

  def accessible_works
    models = Hyrax.config.curation_concerns.map { |m| "\"#{m}\"" }
    query = "has_model_ssim:(#{models.join(' OR ')})"
    
    if @center_tesim.present?
      query += " AND center_tesim:\"#{@center_tesim}\""
    end

    if @member_of_collection_ids_ssim.present?
      query += " AND member_of_collection_ids_ssim:#{@member_of_collection_ids_ssim}"
    end

    fl = 'id, title_tesim, member_of_collection_ids_ssim, file_set_ids_ssim, center_tesim'
    
    ActiveFedora::SolrService.query(query, fl: fl, rows: 50_000)
  end

  def get_collection_name(member_ids)
    member_names = []
    member_ids.each do |member_id|
      c = Collection.find(member_id)
      if c
        member_names << c.title.first
      else
        member_names << member_id
      end
    end
    member_names
  end
end
