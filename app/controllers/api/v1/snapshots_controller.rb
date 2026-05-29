module Api
  module V1
    class SnapshotsController < ApplicationController
      include ApiKeyAuthentication

      allow_unauthenticated_access
      skip_before_action :track_ahoy_visit

      before_action :require_type, only: :latest
      before_action :validate_type, only: [ :index, :latest ]

      rescue_from ActiveRecord::RecordNotFound do
        render json: { error: "Snapshot not found" }, status: :not_found
      end

      def index
        @snapshots = Aact::Snapshot.of_type(params[:type]).recent
      end

      def show
        @snapshot = Aact::Snapshot.find(params[:id])
      end

      def latest
        @snapshot = Aact::Snapshot.latest_of_type(params[:type])
        raise ActiveRecord::RecordNotFound unless @snapshot
      end

      def download
        snapshot = Aact::Snapshot.find(params[:id])
        # TODO stage 2: log Analytics::SnapshotDownload event with user from API key
        # (deferred until API key auth lands — see ApiKeyAuthentication concern)
        redirect_to snapshot.url, allow_other_host: true
      end

      private

      def require_type
        return if params[:type].present?

        render json: {
          error: "type parameter is required",
          available_types: Aact::Snapshot::TYPE_MAPPING.keys
        }, status: :bad_request
      end

      def validate_type
        return if params[:type].blank?
        return if Aact::Snapshot::TYPE_MAPPING.key?(params[:type])

        render json: {
          error: "Invalid type",
          available_types: Aact::Snapshot::TYPE_MAPPING.keys
        }, status: :bad_request
      end
    end
  end
end
