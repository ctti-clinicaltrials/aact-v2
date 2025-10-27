class AddFieldsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :name, :string
    add_column :users, :admin, :boolean, default: false, null: false
    add_column :users, :database_username, :string
    add_column :users, :database_password, :string
    add_column :users, :database_user_created, :boolean, default: false, null: false
  end
end
