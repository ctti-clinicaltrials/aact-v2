class AddFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_name, :string, limit: 50
    add_column :users, :last_name, :string, limit: 50
    add_column :users, :legacy_user_id, :bigint
    add_index :users, :legacy_user_id, unique: true, where: "legacy_user_id IS NOT NULL"
  end
end
