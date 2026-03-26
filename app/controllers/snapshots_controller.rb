class SnapshotsController < ApplicationController
  allow_unauthenticated_access

  before_action :set_service
  before_action :validate_type, only: [:archive]

  def index
    @latest_snapshots = @service.latest
  end

  def archive
    @type = params[:type]
    @pagy, @daily_snapshots = pagy(@service.daily(@type), limit: 10)
    @monthly_snapshots = @service.monthly(@type)
    @year = params[:year] || Date.today.year.to_s
  end

  private

  def set_service
    @service = SnapshotsService.new
  end

  def validate_type
    redirect_to snapshots_path unless Aact::Snapshot::TYPE_MAPPING.key?(params[:type])
  end
end
