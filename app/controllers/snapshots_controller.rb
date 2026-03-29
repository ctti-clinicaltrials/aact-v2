class SnapshotsController < ApplicationController
  before_action :set_service, only: [ :index, :archive ]
  before_action :validate_type, only: [ :archive ]

  def index
    @latest_snapshots = @service.latest
  end

  def archive
    @type = params[:type]
    @pagy, @daily_snapshots = pagy(@service.daily(@type), limit: 10)
    @monthly_snapshots = @service.monthly(@type)
    @year = params[:year] || Date.today.year.to_s
  end

  def download
    snapshot = Aact::Snapshot.find(params[:id])
    redirect_to snapshot.url, allow_other_host: true
  rescue ActiveRecord::RecordNotFound
    redirect_to snapshots_path, alert: "Snapshot not found."
  ensure
    begin
      Analytics::SnapshotDownload.create!(
        user: Current.user,
        file_type: snapshot.api_type,
        snapshot_id: snapshot.id.to_s,
        source: "web",
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      ) if snapshot
    rescue => e
      Rails.logger.error "[SnapshotDownload] Analytics recording failed: #{e.message}"
      Sentry.capture_exception(e,
        tags: { feature: "snapshot_download" },
        extra: {
          snapshot_id: snapshot&.id,
          file_type: snapshot&.api_type,
          user_id: Current.user&.id
        }
      )
    end
  end

  private

  def set_service
    @service = SnapshotsService.new
  end

  def validate_type
    redirect_to snapshots_path unless Aact::Snapshot::TYPE_MAPPING.key?(params[:type])
  end
end
