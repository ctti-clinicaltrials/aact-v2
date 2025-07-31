module Api
  module V1
    class AnalyticsController < ApplicationController
      before_action :set_date_params, only: [ :database_usage, :user_usage ]

      def database_usage
        @service = AactPublicAnalyticsService.new(**@date_params)
        @metrics = @service.database_usage_metrics

        respond_to do |format|
          format.json { render json: @metrics }
        end
      end

      def user_usage
        @service = AactPublicAnalyticsService.new(**@date_params)
        @users = @service.user_usage_metrics

        respond_to do |format|
          format.json { render json: @users }
        end
      end

      private
      def set_date_params
        @date_params = {
          start_date: params[:start_date],
          end_date: params[:end_date],
          period: params[:period] || "daily"
        }
      end
    end
  end
end
