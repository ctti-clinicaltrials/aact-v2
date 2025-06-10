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
end
