# Rake tasks to sync analytics from Matomo.
#
# Notes:
# - wpi:sync_analytics: full sync (long-running). This iterates through every work
#   and file_set, fetching stats individually from Matomo. Expect it to take
#   significantly longer for large repositories.
# - wpi:sync_matomo_analytics: faster aggregated sync. This fetches stats for a
#   date range and imports them in bulk and is typically much faster than the
#   full per-object sync.
#
# How to run:
# - Locally:    bundle exec rake wpi:sync_analytics
# - Production: RAILS_ENV=production bundle exec rake wpi:sync_analytics
# - Or use the faster aggregated task: bundle exec rake wpi:sync_matomo_analytics
# Both tasks enqueue background jobs (they call perform_later), so ensure your
# background worker (e.g. Sidekiq) is running to process the jobs.

namespace :wpi do
  desc 'Sync analytics data'
  task sync_analytics: :environment do
    user = Role.find_by(name: 'admin').users.first
    AnalyticsSyncJob.perform_later(user.id)
  end

  desc 'Sync analytics data from Matomo in an optimized way'
  task sync_matomo_analytics: :environment do
    MatomoAnalyticsSyncJob.perform_later
  end
end