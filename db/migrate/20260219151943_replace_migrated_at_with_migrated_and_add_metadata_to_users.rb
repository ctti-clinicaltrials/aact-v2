class ReplaceMigratedAtWithMigratedAndAddMetadataToUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :migrated_at, :timestamp
    add_column :users, :migrated, :boolean, default: false, null: false
    add_column :users, :metadata, :jsonb
  end
end
