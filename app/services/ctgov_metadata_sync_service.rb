class CtgovMetadataSyncService
  API_URL = "https://clinicaltrials.gov/api/v2/studies/metadata"

  def initialize(api_version: "2", source: :api)
    @api_version = api_version
    @source = source # :api or :file
  end

  def sync
    json_response = fetch_metadata

    # Check if metadata has changed
    unless CtgovMetadataSnapshot.has_changed?(json_response, @api_version)
      Rails.logger.info "No changes detected in CTGov metadata"
      return { status: :unchanged, message: "Metadata unchanged" }
    end

    ActiveRecord::Base.transaction do
      # 1. Save snapshot
      snapshot = save_snapshot(json_response)

      # 2. Flatten JSON
      flattened_records = flatten_metadata(json_response)

      # 3. Upsert metadata (mark all as active)
      upsert_metadata(flattened_records)

      # 4. Soft delete missing records
      mark_inactive_records(flattened_records)

      {
        status: :success,
        snapshot_id: snapshot.id,
        field_count: flattened_records.size,
        message: "Synced #{flattened_records.size} metadata fields"
      }
    end
  rescue StandardError => e
    Rails.logger.error "Failed to sync CTGov metadata: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    { status: :error, message: e.message }
  end

  private

  def fetch_metadata
    case @source
    when :api
      fetch_from_api
    when :file
      fetch_from_file
    else
      raise ArgumentError, "Invalid source: #{@source}"
    end
  end

  def fetch_from_api
    conn = Faraday.new do |f|
      f.request :retry, max: 3, interval: 1
      f.adapter Faraday.default_adapter
      f.options.timeout = 30
    end

    response = conn.get(API_URL)

    unless response.success?
      raise "API request failed: #{response.status}"
    end

    JSON.parse(response.body)
  rescue Faraday::Error => e
    raise "HTTP error fetching metadata: #{e.message}"
  end

  def fetch_from_file
    # For testing/development - load from local file
    file_path = Rails.root.join("lib", "ctgov", "metadata.json")
    unless File.exist?(file_path)
      raise "Metadata file not found: #{file_path}"
    end

    JSON.parse(File.read(file_path))
  end

  def save_snapshot(json_response)
    CtgovMetadataSnapshot.create!(
      api_version: @api_version,
      snapshot: json_response,
      field_count: nil, # Will be calculated by model callback
      checksum: nil     # Will be calculated by model callback
    )
  end

  def flatten_metadata(json_response)
    flattener = CtgovMetadataFlattener.new(json_response, api_version: @api_version)
    flattener.flatten
  end

  def upsert_metadata(records)
    # Rails 8 built-in upsert_all
    CtgovMetadata.upsert_all(
      records,
      unique_by: :path,
      update_only: [
        :name, :piece, :title, :source_type, :type,
        :is_enum, :max_chars, :description, :rules, :synonyms,
        :alt_piece_names, :ded_link_label, :ded_link_url,
        :active, :api_version
      ]
      # updated_at is handled automatically by Rails
    )
  end

  def mark_inactive_records(current_records)
    current_paths = current_records.map { |r| r[:path] }

    CtgovMetadata
      .where(api_version: @api_version)
      .where.not(path: current_paths)
      .update_all(active: false, updated_at: Time.current)
  end
end
