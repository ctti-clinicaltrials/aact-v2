class AddSourceToAnalyticsSnapshotDownloads < ActiveRecord::Migration[8.0]
  def change
    add_column :analytics_snapshot_downloads, :source, :string, null: false, default: "web"
    add_index :analytics_snapshot_downloads, :source

    User.find_or_create_by!(email_address: "legacy@aact.system") do |u|
      u.name = "AACT Legacy"
      u.password = SecureRandom.hex(32)
    end
  end
end
