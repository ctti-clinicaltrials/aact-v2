class AddDatabaseCreationStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    # keep all options to support rollback
    remove_column :users, :database_user_created, :boolean, default: false, null: false

    add_column :users, :database_creation_status, :string, default: "not_requested", null: false
    add_column :users, :database_creation_error, :text, null: true
    add_column :users, :database_creation_attempted_at, :datetime, null: true

    add_index :users, :database_creation_status
  end
end
