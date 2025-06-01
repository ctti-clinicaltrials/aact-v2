namespace :logs do
  desc "Download Postgres logs for a specific day"
  task :download, [ :date ] => :environment do |t, args|
    date_str = args[:date] || Date.yesterday.strftime("%a")
    service = LogsDownloadService.new(date_str)
    puts "Downloading Postgres logs for day: #{date_str}"

    file_path = service.download_logs
    puts "Downloaded to: #{file_path}"
    puts "File size: #{File.size(file_path) / 1024.0} KB"
  end
end
