class CtgovMetadataFlattener
  def initialize(json_response, api_version: "2")
    @json = json_response
    @api_version = api_version
  end

  # Returns array of hashes ready for upsert
  def flatten
    flatten_node(@json, path: [])
  end

  private

  def flatten_node(node, path:)
    return [] if node.nil?

    # Handle array of root nodes
    if node.is_a?(Array)
      return node.flat_map { |child| flatten_node(child, path: path) }
    end

    # Handle object node
    return [] unless node.is_a?(Hash)

    current_path = path + [node["name"]]

    # If node has children, it's a parent - recurse into children
    if node["children"].present?
      return node["children"].flat_map do |child|
        flatten_node(child, path: current_path)
      end
    end

    # Leaf node - extract all fields
    [build_metadata_record(node, current_path)]
  end

  def build_metadata_record(node, path_array)
    {
      path: path_array.join("."),
      name: node["name"],
      piece: node["piece"],
      title: node["title"],
      source_type: node["sourceType"],
      type: node["type"],
      is_enum: node["isEnum"],
      max_chars: node["maxChars"],
      description: node["description"],
      rules: node["rules"],
      synonyms: node["synonyms"],
      alt_piece_names: node["altPieceNames"] || [],
      ded_link_label: node.dig("dedLink", "label"),
      ded_link_url: node.dig("dedLink", "url"),
      active: true,
      api_version: @api_version
    }
    # Don't include timestamps - Rails upsert_all handles them automatically
  end
end
