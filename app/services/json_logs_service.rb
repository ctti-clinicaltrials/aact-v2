require "net/http"
require "json"

class JsonLogsService
  BASE_URL = "https://ctti-aact.nyc3.digitaloceanspaces.com/pgbadger/json"

  def initialize(date = nil)
    @date = date&.is_a?(String) ? Date.parse(date) : (date || Date.yesterday)
    @date_str = @date.strftime("%Y-%m-%d")

    @temp_dir = Rails.root.join("tmp", "aact_public")
    FileUtils.mkdir_p(@temp_dir)
  end

  def process_daily_logs
    file_path = download_json_logs
    metrics = extract_metrics_from_json(file_path)
    persist_metrics(metrics)
  ensure
    cleanup_file(file_path) if file_path&.exist?
  end

  private

  def download_json_logs
    url = "#{BASE_URL}/#{@date_str}.json"
    local_file_path = @temp_dir.join("pgbadger-#{@date_str}.json")
    uri = URI(url)
    puts "Downloading JSON logs from: #{url}"

    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      request = Net::HTTP::Get.new(uri)
      # streaming - process chunks as they arrive
      http.request(request) do |response|
        unless response.is_a?(Net::HTTPSuccess)
          raise "Failed to download logs: HTTP #{response.code} - #{response.message}"
        end
        # Write binary data directly to file
        File.open(local_file_path, "wb") do |file|
          response.read_body do |chunk|
            file.write(chunk)
          end
        end
      end
    end
    puts "Downloade file size: #{(File.size(local_file_path) / 1024.0 / 1024.0).round(2)} MB"
    local_file_path
  end

  def extract_metrics_from_json(file_path)
    content = File.read(file_path, encoding: "utf-8")
    json_data = JSON.parse(content)
    users_data = json_data.dig("user_info", "postgres") || {}
    puts "Found #{users_data.keys.length} users in logs"
    # return limited set
    users_data.transform_values do |stats|
      {
        "count" => stats["count"] || 0,
        "duration" => stats["duration"] || 0.0
      }
    end
  rescue StandardError => e
    Rails.logger.error "Failed to extract metrics from JSON: #{e.message}"
    raise e
  end

  def persist_metrics(data)
    current_time = Time.current
    # Prepare bulk insert data
    metrics = data.map do |username, stats|
      {
        log_date: @date,
        username: username,
        query_count: stats["count"],
        total_duration_ms: stats["duration"],
        created_at: current_time,
        updated_at: current_time
      }
    end

    # bulk insert
    AactPublicQueryMetric.upsert_all(
      metrics,
      unique_by: [ :log_date, :username ],
      update_only: [ :query_count, :total_duration_ms, :updated_at ],
      record_timestamps: false
    )

    puts "✓ Bulk inserted/updated #{metrics.size} metrics"
  rescue StandardError => e
    Rails.logger.error "Failed to persist metrics: #{e.message}"
    raise e
  end

  def cleanup_file(file_path)
    File.delete(file_path) if file_path.exist?
    puts "✓ Cleaned up downloaded file"
  end
end
