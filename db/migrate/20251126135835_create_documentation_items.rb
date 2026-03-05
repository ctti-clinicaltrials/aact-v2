class CreateDocumentationItems < ActiveRecord::Migration[8.0]
  def change
    create_table :documentation_items do |t|
      t.boolean :active, default: true
      t.string :table_name, null: false
      t.string :column_name, null: false
      t.string :data_type
      t.boolean :nullable
      t.text :description
      # Denormalized CTGov fields
      t.string :ctgov_name
      t.string :ctgov_label
      t.string :ctgov_path
      t.string :ctgov_section
      t.string :ctgov_module
      t.string :ctgov_url
      t.timestamps
    end

    add_index :documentation_items, :table_name
    add_index :documentation_items, :active
    add_index :documentation_items, [ :table_name, :column_name ], unique: true
  end
end
