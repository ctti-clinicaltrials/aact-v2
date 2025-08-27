module Api
  module V1
    class LogsController < ApplicationController
      skip_before_action :verify_authenticity_token, only: [ :process_json ]

      # POST /api/v1/logs/process_json
      def process_json
        date = params[:date] || Date.yesterday.strftime("%Y-%m-%d")

        Rails.logger.info "Processing JSON logs request for date: #{date}"
        begin
          job_id = ::JsonLogsProcessorWorker.perform_async(date)

          render json: {
            status: "success",
            message: "Log processing job queued",
            date: date,
            job_id: job_id
          }
        rescue => e
          Rails.logger.error "Error processing logs request: #{e.message}"
          render json: {
            status: "error",
            message: "Failed to queue log processing job",
            error: e.message
          }, status: :internal_server_error
        end
      end
    end
  end
end
