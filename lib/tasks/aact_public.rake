# rake logs:download
# bin/bundle exec rake "logs:download[Sun]"

namespace :logs do
  desc "Download Postgres logs for a specific day"
  task :download, [ :date ] => :environment do |t, args|
    date_str = args[:date] || Date.yesterday.strftime("%a")
    service = LogsService.new(date_str)
    puts "Downloading Postgres logs for day: #{date_str}"

    file_path = service.download_logs
    puts "Downloaded to: #{file_path}"
    puts "File size: #{File.size(file_path) / 1024.0} KB"
  end

  desc "Process downloaded Postgres logs"
  task :process, [ :file_path ] => :environment do |t, args|
    file_path = args[:file_path] || Rails.root.join("tmp", "aact_public_logs", "postgresql-#{Date.yesterday.strftime("%a")}.csv")
    service = LogsService.new
    puts "Processing Postgres logs from: #{file_path}"

    if File.exist?(file_path)
      service.process_logs(file_path)
      puts "Logs processed successfully."
    else
      puts "File not found: #{file_path}"
      raise "File not found error"
    end
  end

  # TODO: switch to processing by date
  desc "Download and process logs for yesterday (combined task)"
  task daily_process: :environment do
    date_str = Date.yesterday.strftime("%a")

    puts "=== Starting Daily Log Processing for #{date_str} ==="
    Rails.logger.info "Daily log processing started for #{date_str}"

    begin
      # Download
      puts "Step 1: Downloading logs..."
      service = LogsService.new(date_str)
      file_path = service.download_logs
      puts "✓ Downloaded to: #{file_path}"
      puts "File size: #{(File.size(file_path) / 1024.0 / 1024.0).round(2)} MB"

      # Process
      puts "Step 2: Processing logs..."
      service.process_logs(file_path)
      puts "✓ Processing completed successfully"

      # Cleanup
      puts "Step 3: Cleaning up..."
      File.delete(file_path) if File.exist?(file_path)
      puts "✓ Cleaned up log file"

      puts "=== Daily Log Processing Completed Successfully ==="
      Rails.logger.info "Daily log processing completed successfully for #{date_str}"

    rescue StandardError => e
      puts "❌ Error: #{e.message}"
      puts "❌ Backtrace: #{e.backtrace.first(5).join("\n")}"
      Rails.logger.error "Daily log processing failed for #{date_str}: #{e.message}"
      raise e
    end
  end

  desc "Process JSON logs for a specific date"
  task :process_json, [ :date ] => :environment do |t, args|
    date = args[:date] || Date.yesterday.strftime("%Y-%m-%d")

    puts "=== Processing JSON logs for #{date} ==="
    service = JsonLogsService.new(date)
    service.process_daily_logs
    puts "=== JSON log processing completed ==="
  end

  desc "Download and process JSON logs for yesterday"
  task daily_process_json: :environment do
    date = Date.yesterday

    puts "=== Starting Daily JSON Log Processing for #{date} ==="
    Rails.logger.info "Daily JSON log processing started for #{date}"

    begin
      service = JsonLogsService.new(date)
      service.process_daily_logs

      puts "=== Daily JSON Log Processing Completed Successfully ==="
      Rails.logger.info "Daily JSON log processing completed successfully for #{date}"
    rescue StandardError => e
      puts "❌ Error: #{e.message}"
      Rails.logger.error "Daily JSON log processing failed for #{date}: #{e.message}"
      raise e
    end
  end
end
