class SyncDocumentationJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting documentation sync..."

    # Build all records from external DB
    records = build_all_records

    # Truncate and insert in a transaction
    DocumentationItem.transaction do
      DocumentationItem.delete_all
      DocumentationItem.insert_all(records) if records.any?
    end

    # Clear cached table names since data has changed
    # NOTE: If DocumentationItem caching strategy changes, update this accordingly
    DocumentationItem.clear_table_names_cache

    Rails.logger.info "Documentation sync complete: #{records.size} records"
  end

  private

  def build_all_records
    # Fetch all from external DB (one-time load)
    schemas = Ctgov::V1Schema.all
    mappings = Ctgov::V1Mapping.all.index_by { |m| [ m.table_name, m.field_name ] }
    metadata = Ctgov::V1ApiMetadata.all.index_by(&:path)

    now = Time.current

    schemas.map do |schema|
      mapping = mappings[[ schema.table_name, schema.column_name ]]
      meta = mapping ? metadata[mapping.api_path] : nil

      {
        active: schema.active,
        table_name: schema.table_name,
        column_name: schema.column_name,
        data_type: schema.data_type,
        nullable: schema.nullable,
        description: schema.description,
        ctgov_name: meta&.name,
        ctgov_label: meta&.formatted_piece,
        ctgov_path: meta&.path,
        ctgov_section: meta&.ctgov_section,
        ctgov_module: meta&.ctgov_module,
        ctgov_url: meta&.url,
        created_at: now,
        updated_at: now
      }
    end
  end
end
