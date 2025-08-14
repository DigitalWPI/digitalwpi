class CreateAnalyticsSyncLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :analytics_sync_logs do |t|
      t.string :sync_type
      t.datetime :last_synced_at

      t.timestamps
    end

    add_index :analytics_sync_logs, :sync_type, unique: true
  end
end
