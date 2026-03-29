module Api
  module V1
    class DownloadEventsController < InternalController
      def create
        return head :unprocessable_entity if params[:snapshot_id].blank?

        snapshot = Aact::Snapshot.find(params[:snapshot_id])

        AdminDownloadEventJob.perform_later(
          user_id: @current_user.id,
          file_type: snapshot.api_type,
          snapshot_id: snapshot.id.to_s,
          source: params.fetch(:source, "web"),
          ip_address: params[:ip_address],
          user_agent: params[:user_agent]
        )

        head :accepted
      rescue ActiveRecord::RecordNotFound => e
        Sentry.capture_exception(e,
          tags: { feature: "admin_download_event" },
          extra: { snapshot_id: params[:snapshot_id] }
        )
        head :accepted
      end
    end
  end
end
