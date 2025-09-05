namespace :wpi do
  desc 'Sync analytics data'
  task sync_analytics: :environment do
    user = Role.find_by(name: 'admin').users.first
    AnalyticsSyncJob.perform_later(user.id)
  end
end