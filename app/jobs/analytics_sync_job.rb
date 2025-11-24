class AnalyticsSyncJob < Hyrax::ApplicationJob
  queue_as :default
  attr_reader :current_user

  def perform(user_id)
    @current_user = User.find_by(id: user_id)

    %w(work_views file_views file_downloads).each do |sync_type|
      sync_log = AnalyticsSyncLog.find_or_initialize_by(sync_type: sync_type)
      from_date = sync_log.persisted? ? (sync_log.last_synced_at&.to_date - 1.day) : Hyrax.config.analytics_start_date.to_date

      next if from_date >= (Date.today - 1.day)

      if sync_type == "work_views"
        accessible_works.each do |work|
          pageviews = Hyrax::Analytics.daily_events_for_url(page_url(sync_type, work), date_ranges(from_date))
          pageviews.results.each do |date, views_count|
            if views_count > 0
              stat = WorkViewStat.find_or_initialize_by(date: date, work_id: work.id)
              stat.work_views = [stat.work_views.to_i, views_count.to_i].max

              stat.save!
            end
          end
        end
      elsif sync_type == "file_views"
        accessible_file_sets.each do |file|
          pageviews = Hyrax::Analytics.daily_events_for_url(page_url(sync_type, file), date_ranges(from_date))
          pageviews.results.each do |date, views_count|
            if views_count > 0
              stat = FileViewStat.find_or_initialize_by(date: date, file_id: file.id)
              stat.views = [stat.views.to_i, views_count.to_i].max

              stat.save!
            end
          end
        end
      elsif sync_type == "file_downloads"
        accessible_file_sets.each do |file|
          downloads = Hyrax::Analytics.daily_events_for_id(file.id, 'file-set-download', date_range_for_download_statistics(from_date))
          downloads.results.each do |date, downloads_count|
            if downloads_count > 0
              create_download_stat(file, date, downloads_count)
            end
          end
        end
      end

      sync_log.last_synced_at = Date.today
      sync_log.save!  
    end
  end

  private

  def accessible_works
    models = Hyrax.config.curation_concerns.map { |m| "\"#{m}\"" }
    if current_user.ability.admin?
      ActiveFedora::SolrService.query("has_model_ssim:(#{models.join(' OR ')})",
        fl: 'has_model_ssim, title_tesim, id, member_of_collections',
        rows: 50_000)
    else
      ActiveFedora::SolrService.query(
        "edit_access_person_ssim:#{current_user} AND has_model_ssim:(#{models.join(' OR ')})",
        fl: 'has_model_ssim, title_tesim, id, member_of_collections',
        rows: 50_000
      )
    end
  end

  def accessible_file_sets
    if current_user.ability.admin?
      ActiveFedora::SolrService.query(
        "has_model_ssim:FileSet",
        fl: 'has_model_ssim, title_tesim, id',
        rows: 50_000
      )
    else
      ActiveFedora::SolrService.query(
        "edit_access_person_ssim:#{current_user} AND has_model_ssim:FileSet",
        fl: 'has_model_ssim, title_tesim, id',
        rows: 50_000
      )
    end
  end

  def page_url(sync_type, object)
    if sync_type == 'file_views'
      Rails.application.routes.url_helpers.hyrax_file_set_path(object['id'])
    else
      "concern/#{object['has_model_ssim'][0].underscore.pluralize}/#{object['id']}"
    end
  end

  def date_ranges(start_date)
    start_date = start_date || Hyrax.config.analytics_start_date
    end_date = Date.today

    ranges = []
    current_start = start_date

    while current_start <= end_date
      current_end = [current_start.next_year - 1, end_date].min
      ranges << "#{current_start},#{current_end}"
      current_start = current_end + 1
    end

    ranges
  end

  def date_range_for_download_statistics(start_date)
    start_date = start_date || Hyrax.config.analytics_start_date
    end_date = Date.today
    "#{start_date},#{end_date}"
  end

  def create_download_stat(file, date, downloads_count)
    stat = FileDownloadStat.find_or_initialize_by(date: date, file_id: file.id)
    stat.downloads = [stat.downloads.to_i, downloads_count.to_i].max
    stat.save!
  end
end
