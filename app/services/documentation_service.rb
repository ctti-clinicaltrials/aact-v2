class DocumentationService
  def initialize(search: nil, table: nil, active: nil)
    @search = search
    @table = table
    @active = active
  end

  def build_documentation_scope
    apply_filters(Ctgov::V1Schema.order(:table_name, :column_name))
  end

  def build_documentation_for_records(records)
    # Load all mappings and metadata upfront
    mapping_hash = build_mapping_hash
    metadata_hash = build_metadata_hash

    # Build documentation for given records
    records.map do |schema_field|
      mapping = mapping_hash.dig(schema_field.table_name, schema_field.column_name)
      meta_info = mapping ? metadata_hash[mapping.api_path] : nil

      build_doc_item(schema_field, meta_info)
    end
  end

  def find_by_id(id)
    schema_field = Ctgov::V1Schema.find_by(id: id)
    return nil unless schema_field

    # Find associated mapping and metadata
    mapping = Ctgov::V1Mapping.find_by(
      table_name: schema_field.table_name,
      field_name: schema_field.column_name
    )
    meta_info = mapping ? Ctgov::V1ApiMetadata.find_by(path: mapping.api_path) : nil

    build_doc_item(schema_field, meta_info)
  end

  private

  def apply_filters(scope)
    scope = scope.where(table_name: @table) if @table.present?
    scope = scope.where(active: @active) if !@active.nil?

    if @search.present?
      search_term = "%#{@search}%"
      scope = scope.where(
        "table_name ILIKE ? OR column_name ILIKE ? OR data_type ILIKE ? OR description ILIKE ?",
        search_term, search_term, search_term, search_term
      )
    end

    scope
  end

  def build_mapping_hash
    # Group mappings by table_name and field_name for fast lookup
    Ctgov::V1Mapping.all.each_with_object({}) do |mapping, hash|
      hash[mapping.table_name] ||= {}
      hash[mapping.table_name][mapping.field_name] = mapping
    end
  end

  def build_metadata_hash
    # Index metadata by path for fast lookup
    Ctgov::V1ApiMetadata.all.index_by(&:path)
  end

  def build_doc_item(schema_field, meta_info)
    {
      id: schema_field.id,
      active: schema_field.active,
      table_name: schema_field.table_name,
      column_name: schema_field.column_name,
      data_type: schema_field.data_type,
      nullable: schema_field.nullable,
      description: schema_field.description,
      # CTGov API metadata
      ctgov_data_point_name: meta_info&.name,
      ctgov_data_point_label: meta_info&.formatted_piece,
      ctgov_data_type: meta_info&.data_type,
      ctgov_source_type: meta_info&.source_type,
      ctgov_synonyms: meta_info&.synonyms,
      ctgov_url_label: meta_info&.label,
      ctgov_url: meta_info&.url,
      ctgov_section: meta_info&.ctgov_section,
      ctgov_module: meta_info&.ctgov_module,
      ctgov_path: meta_info&.path
    }
  end
end
