class MatomoAnalyticsSyncJob < Hyrax::ApplicationJob
  queue_as :default

  def perform
    %w(work_views file_views file_downloads).each do |sync_type|
      # Find or initialize the sync log for this sync type. This record stores
      # the timestamp of the last successful sync so we can resume from there.
      sync_log = AnalyticsSyncLog.find_or_initialize_by(sync_type: sync_type)
      # Determine the from_date for the analytics query:
      # - If we have a persisted sync_log, start from the previous last_synced_at
      #   minus one day (to ensure we reprocess the most recent day in case of updates).
      # - Otherwise, use the configured analytics start date.
      from_date = sync_log.persisted? ? (sync_log.last_synced_at&.to_date - 1.day) : Hyrax.config.analytics_start_date.to_date

      next if from_date >= (Date.today - 1.day)

      if sync_type == "work_views"
        pageviews = Hyrax::Analytics.daily_events_for_import('work-view', date_range(from_date))

        pageviews.each do |date, results|
          results.each do |result|
            work_id = result['label']&.split(' - ')[1]
            work = accessible_work(work_id)
            next unless work
            nb_visits = result['nb_uniq_visitors'].to_i
            if nb_visits > 0
              stat = WorkViewStat.find_or_initialize_by(date: date, work_id: work.id)
              stat.work_views = [stat.work_views.to_i, nb_visits].max
              stat.save!
            end
          end
        end
      elsif sync_type == "file_views"
        pageviews = Hyrax::Analytics.daily_events_for_import('file-set-view', date_range(from_date))

        pageviews.each do |date, results|
          results.each do |result|
            file_id = result['label']&.split(' - ')[1]
            file = accessible_file_set(file_id)
            next unless file
            nb_visits = result['nb_uniq_visitors'].to_i
            if nb_visits > 0
              stat = FileViewStat.find_or_initialize_by(date: date, file_id: file.id)
              stat.views = [stat.views.to_i, nb_visits].max
              stat.save!
            end
          end
        end
      elsif sync_type == "file_downloads"
        downloads = Hyrax::Analytics.daily_events_for_import('file-set-download', date_range(from_date))
        downloads.each do |date, results|
          results.each do |result|
            file_id = result['label']&.split(' - ')[1]
            file = accessible_file_set(file_id)
            next unless file
            nb_visits = result['nb_uniq_visitors'].to_i
            if nb_visits > 0
              stat = FileDownloadStat.find_or_initialize_by(date: date, file_id: file.id)
              stat.downloads = [stat.downloads.to_i, nb_visits].max
              stat.save!
            end
          end
        end
      end

      # Update the sync log to indicate we've synced up to today so subsequent
      # runs start from this point.
      sync_log.last_synced_at = Date.today
      sync_log.save!  
    end

    clear_empty_stats
  end

  private

  def accessible_work(id)
    object = ActiveFedora::Base.find(id)
    return object.work? ? object : nil
  end

  def accessible_file_set(id)
    object = ActiveFedora::Base.find(id)
    return object.file_set? ? object : nil
  end

  def date_range(start_date)
    start_date = start_date || Hyrax.config.analytics_start_date
    end_date = Date.today

    "#{start_date},#{end_date}"
  end

  def clear_empty_stats
    WorkViewStat.where(work_views: [nil, 0]).delete_all
    FileViewStat.where(views: [nil, 0]).delete_all
    FileDownloadStat.where(downloads: [nil, 0]).delete_all
  end
end
