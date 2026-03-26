class DownloadsController < ApplicationController
  allow_unauthenticated_access

  before_action :set_service

  def index
    @latest_snapshots = @service.latest
  end

  def snapshots
    @type = params[:type]
    @pagy, @daily_snapshots = pagy(@service.daily(@type), limit: 10)
    @monthly_snapshots = @service.monthly(@type)
    @year = params[:year] || Date.today.year.to_s
  end

  def postgres_instructions
    render "downloads/instructions/postgres"
  end

  def flatfiles_instructions
    render "downloads/instructions/flatfiles"
  end

  def covid19_instructions
    render "downloads/instructions/covid19"
  end

  private

  def set_service
    @service = SnapshotsService.new
  end
end
