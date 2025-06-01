class LogsDownloadService
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
      puts "Failed to download logs. Please check the remote host and file path."
      raise error_msg
    end
  end
end
