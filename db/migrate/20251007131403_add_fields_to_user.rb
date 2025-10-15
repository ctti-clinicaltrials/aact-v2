class AddFieldsToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :username, :string
    add_column :users, :name, :string

    add_index :users, :username, unique: true
  end
end
