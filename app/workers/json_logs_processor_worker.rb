class JsonLogsProcessorWorker
  include Sidekiq::Worker
  sidekiq_options queue: "logs", retry: 3

  def perform(date = nil)
    date = date || Date.yesterday.strftime("%Y-%m-%d")
    Rails.logger.info "Processing JSON logs for #{date}"
    puts "=== Processing JSON logs for #{date} ==="

    service = JsonLogsService.new(date)
    service.process_daily_logs

    puts "=== JSON log processing completed ==="
    Rails.logger.info "Completed processing JSON logs for #{date}"
  end
end
