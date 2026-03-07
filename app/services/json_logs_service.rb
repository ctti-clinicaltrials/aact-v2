require "net/http"
require "oj"

class JsonLogsService
  BASE_URL = "https://ctti-aact.nyc3.digitaloceanspaces.com/pgbadger/json"

  class PostgresUsageExtractor < Oj::Saj
    attr_reader :result

    def initialize
      @result = {}
      @state = :scanning
      @depth = 0
      @user_info_depth = nil
      @postgres_depth = nil
      @user_depth = nil
      @current_user = nil
      @current_stats = {}
    end

    def hash_start(key)
      @depth += 1

      case @state
      when :scanning
        if key == "user_info"
          @user_info_depth = @depth
        elsif key == "postgres" && @depth == (@user_info_depth.to_i + 1)
          @state = :in_postgres
          @postgres_depth = @depth
        end
      when :in_postgres
        @state = :in_user
        @current_user = key
        @current_stats = {}
        @user_depth = @depth
      end
      # :in_user — nested hashes inside a user's stats; depth tracks us out
      # :done   — past postgres entirely, ignore everything
    end

    def hash_end(key)
      case @state
      when :in_user
        if @depth == @user_depth
          @result[@current_user] = {
            "count"    => @current_stats.fetch("count", 0),
            "duration" => @current_stats.fetch("duration", 0.0)
          }
          @current_user = nil
          @current_stats = {}
          @state = :in_postgres
        end
      when :in_postgres
        @state = :done if @depth == @postgres_depth
      end

      @depth -= 1
    end

    def add_value(value, key)
      return unless @state == :in_user && @depth == @user_depth
      @current_stats[key] = value if key == "count" || key == "duration"
    end

    def array_start(key) = @depth += 1
    def array_end(key)   = @depth -= 1

    def error(message, line, column)
      raise "JSON parse error at #{line}:#{column} — #{message}"
    end
  end

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
    extractor = PostgresUsageExtractor.new
    File.open(file_path) { |f| Oj.saj_parse(extractor, f) }
    puts "Found #{extractor.result.size} users in logs"
    extractor.result
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
