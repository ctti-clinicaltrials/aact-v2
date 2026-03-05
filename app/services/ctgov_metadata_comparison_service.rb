class CtgovMetadataComparisonService
  def initialize(snapshot_a, snapshot_b)
    @snapshot_a = snapshot_a
    @snapshot_b = snapshot_b
  end

  # Returns hash with: { added: [], removed: [], changed: [], stats: {} }
  def compare
    # Flatten both snapshots into arrays of metadata records
    flattener_a = CtgovMetadataFlattener.new(@snapshot_a.snapshot, api_version: @snapshot_a.api_version)
    flattener_b = CtgovMetadataFlattener.new(@snapshot_b.snapshot, api_version: @snapshot_b.api_version)

    fields_a = flattener_a.flatten.index_by { |f| f[:path] }
    fields_b = flattener_b.flatten.index_by { |f| f[:path] }

    paths_a = fields_a.keys.to_set
    paths_b = fields_b.keys.to_set

    # Calculate differences
    added_paths = paths_b - paths_a
    removed_paths = paths_a - paths_b
    common_paths = paths_a & paths_b

    # Find changed fields (same path, different content)
    changed = []
    unchanged_count = 0

    common_paths.each do |path|
      field_a = fields_a[path]
      field_b = fields_b[path]

      if fields_differ?(field_a, field_b)
        changed << {
          path: path,
          old: field_a,
          new: field_b,
          changes: detect_changes(field_a, field_b)
        }
      else
        unchanged_count += 1
      end
    end

    # Build result
    {
      added: added_paths.map { |path| fields_b[path] }.sort_by { |f| f[:path] },
      removed: removed_paths.map { |path| fields_a[path] }.sort_by { |f| f[:path] },
      changed: changed.sort_by { |c| c[:path] },
      stats: {
        added_count: added_paths.size,
        removed_count: removed_paths.size,
        changed_count: changed.size,
        unchanged_count: unchanged_count,
        total_a: fields_a.size,
        total_b: fields_b.size
      }
    }
  end

  private

  # Compare two field records, ignoring metadata fields like api_version and active
  def fields_differ?(field_a, field_b)
    comparable_keys = [ :name, :piece, :title, :source_type, :type, :is_enum,
                       :max_chars, :description, :rules, :synonyms, :alt_piece_names,
                       :ded_link_label, :ded_link_url ]

    comparable_keys.any? do |key|
      normalize_value(field_a[key]) != normalize_value(field_b[key])
    end
  end

  # Detect which specific fields changed
  def detect_changes(field_a, field_b)
    changes = {}
    comparable_keys = [ :name, :piece, :title, :source_type, :type, :is_enum,
                       :max_chars, :description, :rules, :synonyms, :alt_piece_names,
                       :ded_link_label, :ded_link_url ]

    comparable_keys.each do |key|
      old_val = normalize_value(field_a[key])
      new_val = normalize_value(field_b[key])

      if old_val != new_val
        changes[key] = { old: old_val, new: new_val }
      end
    end

    changes
  end

  # Normalize values for comparison (handle nil vs empty array, etc.)
  def normalize_value(value)
    case value
    when Array
      value.compact.presence
    when String
      value.strip.presence
    else
      value
    end
  end
end
