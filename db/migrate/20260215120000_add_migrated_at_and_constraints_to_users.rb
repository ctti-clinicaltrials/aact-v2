class AddMigratedAtAndConstraintsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :migrated_at, :timestamp
    add_index :users, :database_username, unique: true
    change_column_null :users, :name, false
  end
end
