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

    docs
  end

  private

  def build_response(schema_item, api_info)
    {
      ctgov_schema: schema_item,
      ctgov_api: api_info
    }
  end
end
