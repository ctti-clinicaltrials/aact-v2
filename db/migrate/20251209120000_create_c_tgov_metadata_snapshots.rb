class CreateCTgovMetadataSnapshots < ActiveRecord::Migration[8.0]
  def up
    # Drop unused experimental tables (no restore needed)
    drop_table "ctgov.aact_mappings" if table_exists?("ctgov.aact_mappings")
    drop_table "ctgov.api_metadata" if table_exists?("ctgov.api_metadata")

    # Create snapshots schema
    create_schema :snapshots

    # Create metadata snapshots table in snapshots schema
    create_table "snapshots.ctgov_metadata" do |t|
      t.string :api_version, null: false, default: "2"
      t.jsonb :snapshot, null: false
      t.integer :field_count           # Count of leaf nodes
      t.text :checksum                 # SHA256 hash
      t.timestamps
    end

    add_index "snapshots.ctgov_metadata", :api_version
    add_index "snapshots.ctgov_metadata", :created_at
    add_index "snapshots.ctgov_metadata", :checksum

    # Create metadata table in public schema
    create_table :ctgov_metadata do |t|
      # Core identifiers
      t.string :path, null: false                  # "protocolSection.identificationModule.nctId"
      t.string :name, null: false                  # "nctId"
      t.string :piece                              # "NCTId"
      t.string :title                              # "Study Identification"

      # Type information
      t.string :source_type, null: false           # "TEXT" | "DATE" | "BOOLEAN" | "MARKUP" | "STRUCT" | "TIME"
      t.string :type                               # "nct" | "text" | "Status" | "text[]"

      # Optional fields (from API)
      t.boolean :is_enum                           # true if enum
      t.integer :max_chars                         # For TEXT/MARKUP
      t.text :description                          # Field description
      t.text :rules                                # Validation rules
      t.boolean :synonyms                          # Has alt names
      t.text :alt_piece_names, array: true, default: []  # PostgreSQL array

      # Documentation links
      t.string :ded_link_label                     # "Study Identification"
      t.text :ded_link_url                         # Full URL

      # Tracking
      t.boolean :active, default: true, null: false
      t.string :api_version, null: false, default: "2"

      t.timestamps
    end

    # Indexes
    add_index :ctgov_metadata, :path, unique: true
    add_index :ctgov_metadata, :active
    add_index :ctgov_metadata, :name
    add_index :ctgov_metadata, :source_type
    add_index :ctgov_metadata, :api_version
    add_index :ctgov_metadata, :alt_piece_names, using: :gin
  end

  def down
    drop_table :ctgov_metadata
    drop_table "snapshots.ctgov_metadata"
    drop_schema :snapshots
  end
end
