class CreateAnalyticsSnapshotDownloads < ActiveRecord::Migration[8.0]
  def change
    create_table :analytics_snapshot_downloads do |t|
      t.references :user, null: false, foreign_key: true
      t.string :file_type, null: false
      t.string :snapshot_id, null: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :analytics_snapshot_downloads, :file_type
    add_index :analytics_snapshot_downloads, :created_at
  end
end
