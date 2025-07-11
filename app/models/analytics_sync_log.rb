# app/models/analytics_sync_log.rb
class AnalyticsSyncLog < ApplicationRecord
  validates :sync_type, presence: true, uniqueness: true
end
