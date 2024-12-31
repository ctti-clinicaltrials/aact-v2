class CreateAactMappings < ActiveRecord::Migration[7.2]
  def change
    create_table "ctgov.aact_mappings" do |t|
      t.string :table_name
      t.string :field_name
      t.boolean :active, default: true
      t.string :api_path
      t.references :api_metadata,
                  foreign_key: { to_table: "ctgov.api_metadata", on_delete: :nullify },
                  null: true
      t.timestamps
    end

    add_index "ctgov.aact_mappings", [ :table_name, :field_name, :api_path ], name: "index_aact_mappings_on_table_field_api_path", unique: true
  end
end
