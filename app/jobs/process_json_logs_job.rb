class ProcessJsonLogsJob < ApplicationJob
  queue_as :logs

  def perform(date = nil)
    date ||= Date.yesterday.strftime("%Y-%m-%d")
    Rails.logger.info "Processing JSON logs for #{date}"

    service = JsonLogsService.new(date)
    service.process_daily_logs

    Rails.logger.info "Completed processing JSON logs for #{date}"
  end
end
