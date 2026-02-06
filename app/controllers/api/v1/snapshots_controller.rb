module Api
  module V1
    class SnapshotsController < ApplicationController
      # Skip authentication for API endpoints (server-to-server)
      allow_unauthenticated_access

      before_action :setup_snapshots_service

      def index
        type = params[:type]
        snapshots = @snapshots_service.get_snapshots(type)
        render json: snapshots
      end

      def latest
        render json: @snapshots_service.latest
      end

      private

      def setup_snapshots_service
        @snapshots_service = V1SnapshotsService.new
      end
    end
  end
end
