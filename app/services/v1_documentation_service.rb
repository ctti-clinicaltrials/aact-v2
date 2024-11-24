class V1DocumentationService
  def initialize(schema, mappings, metadata)
    @metadata = metadata
    @mappings = mappings
    @schema = schema
  end

  # Building documentation starting from the schema
  def build_documentation
    docs = []

    @schema.each do |db_item|
      # TODO: refactor (use scopes on mapping)
      mapping = @mappings.find { |map| map.table_name == db_item.table_name && map.field_name == db_item.column_name }

      # Find metadata based on api_path from the mapping (if mapping exists)
      api_info = mapping ? @metadata.find { |meta| meta.path == mapping.api_path } : nil

      # build documentation object
      docs << build_response(db_item, api_info)
    end

    # TODO: handle edge cases like browse_conditions/mesh_term
    docs
  end

  def generate_csv(docs)
    CSV.generate(headers: true, col_sep: "|") do |csv|
      csv << docs.first.keys # adds headers - update names
      docs.each do |doc|
        csv << doc.values
      end
    end
  end

  private

  def build_response(schema_field, meta_info)
    {
      id: schema_field.id,
      active: schema_field.active,
      table_name: schema_field.table_name,
      column_name: schema_field.column_name,
      data_type: schema_field.data_type,
      nullable: schema_field.nullable,
      description: schema_field.description,
      # api metadata fields
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

  def build_csv_response
  end
end
