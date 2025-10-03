module Api
  module V1
    class AnalyticsController < ApplicationController
      # Skip authentication for API endpoints (server-to-server)
      allow_unauthenticated_access
      
      before_action :set_date_params, only: [ :database_usage, :user_usage ]
      before_action :set_service, only: [ :database_usage, :user_usage ]

      def database_usage
        @metrics = @service.database_usage_metrics
        respond_to do |format|
          format.json { render json: @metrics }
        end
      end

      def user_usage
        @users = @service.user_usage_metrics
        respond_to do |format|
          format.json { render json: @users }
        end
      end

      private

      def set_date_params
        @date_params = {
          start_date: params[:start_date],
          end_date: params[:end_date]
        }
      end

      def set_service
        @service = AactPublicAnalyticsService.new(**@date_params)
      end
    end
  end
end
