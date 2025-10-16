namespace :wpi do
  desc 'Sync analytics data'
  task sync_analytics: :environment do
    user = Role.find_by(name: 'admin').users.first
    AnalyticsSyncJob.perform_later(user.id)
  end

  task sync_matomo_analytics: :environment do
    MatomoAnalyticsSyncJob.perform_later
  end
end