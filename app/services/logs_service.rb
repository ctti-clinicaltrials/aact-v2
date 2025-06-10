require "csv"

class LogsService
  def initialize(date_str = nil)
    @date_str = date_str || Date.yesterday.strftime("%a") # ex. Sun
    @remote_host = ENV["LOGS_SERVER_HOST"]
    @remote_user = ENV["LOGS_SERVER_USER"]

    @temp_dir = Rails.root.join("tmp", "aact_public_logs")
    FileUtils.mkdir_p(@temp_dir)
  end

  def download_logs
    local_file_path = @temp_dir.join("postgresql-#{@date_str}.csv")
    remote_file_path = "/aact-files/logs/postgresql-#{@date_str}.csv"

    cmd = "scp #{@remote_user}@#{@remote_host}:#{remote_file_path} #{local_file_path}"
    success = system(cmd)

    if success
      local_file_path
    else
      error_msg = "Failed to download logs. Exit status: #{$?.exitstatus}"
      puts "Failed to download logs. Please check the remote host and file path."
      raise error_msg
    end
  end

  # process file
  def process_logs(file_path)
    metrics = extract_metrics(file_path)
    puts "Metrics extracted: #{metrics.inspect}"
    persist_metrics(metrics)
  end

  private
  # For each row:
  # 1. Skip if not a SELECT command or no username
  # 2. If message contains "execute fetch from <unnamed>" → set skip_next_duration = true
  # 3. If message starts with "duration:"
  #    → If skip_next_duration is true, skip this duration (it's from a cursor fetch)
  #    → Otherwise, count it as a real query and track duration

  def extract_metrics(file_path)
    puts "extracting metrics"
    metrics = initialize_metrics
    puts "metrics initialized: #{metrics.inspect}"

    skip_next_duration = false

    CSV.foreach(file_path, headers: false) do |row|
      command = row[7].to_s      # e.g., "SELECT"
      message = row[13].to_s     # e.g., "duration: 0.837 ms", or "execute fetch from ..."
      user = row[1]              # username

      # Skip if no user or no meaningful command
      next if user.nil? || user.empty? || command != "SELECT"

      # 1. Detect cursor fetch command
      if message.include?("execute fetch from <unnamed>")
        skip_next_duration = true
        next
      end

      # 2. Process only valid durations not triggered by cursor fetch
      if message.start_with?("duration:")
        if skip_next_duration
          skip_next_duration = false # reset
          next
        end

        duration_ms = message.sub(/^duration:\s*/i, "").sub(/\s*ms$/i, "").to_f
        update_metrics(metrics, user, duration_ms)
      end

    rescue StandardError => e
      puts "Error processing row: #{e.message} - Row: #{row.inspect}"
      next
    end

    metrics
  end


  def initialize_metrics
    {
      user_activity: Hash.new(0),
      user_duration: Hash.new(0)
    }
  end

  def update_metrics(metrics, user, duration_ms)
    metrics[:user_activity][user] += 1 if user.present?
    metrics[:user_duration][user] += duration_ms if user.present? && duration_ms.is_a?(Numeric)

    metrics
  end

  def persist_metrics(metrics)
    puts "date_str: #{@date_str} - #{Date.parse(@date_str)} "
    log_date = Date.parse(@date_str) rescue Date.yesterday

    metrics[:user_activity].each do |username, count|
      # Find or create a record for this user and date
      metric = AactPublicQueryMetric.find_or_initialize_by(
        log_date: log_date,
        username: username
      )

      # Update count and duration metrics
      metric.query_count = count
      metric.total_duration_ms = metrics[:user_duration][username].to_f

      if metric.save
        puts "Saved metrics for user: #{username} with #{count} queries, total duration: #{metric.total_duration_ms.round(2)}ms"
      else
        puts "Error saving metrics for #{username}: #{metric.errors.full_messages.join(', ')}"
      end
    end
  end
end
