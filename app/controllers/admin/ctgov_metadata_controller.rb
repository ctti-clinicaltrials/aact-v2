class Admin::CtgovMetadataController < Admin::BaseController
  def index
    @snapshots = CtgovMetadataSnapshot.order(created_at: :desc)
    @total_snapshots = @snapshots.count
    @latest_snapshot = @snapshots.first
    @active_fields_count = CtgovMetadata.active.count
    @total_fields_count = CtgovMetadata.count
  end

  def sync
    Rails.logger.info "🔄 Starting CTGov metadata sync..."
    service = CtgovMetadataSyncService.new(api_version: "2", source: :api)
    result = service.sync
    Rails.logger.info "✅ Sync result: #{result[:status]} - #{result[:message]}"

    @snapshots = CtgovMetadataSnapshot.order(created_at: :desc)
    @total_snapshots = @snapshots.count
    @latest_snapshot = @snapshots.first
    @active_fields_count = CtgovMetadata.active.count
    @total_fields_count = CtgovMetadata.count

    respond_to do |format|
      format.turbo_stream do
        case result[:status]
        when :success
          render turbo_stream: [
            turbo_stream.replace("flash_messages", partial: "shared/flash", locals: {
              type: :success,
              message: "Successfully synced! New snapshot created with #{helpers.number_with_delimiter(result[:field_count])} fields."
            }),
            turbo_stream.replace("summary_cards", partial: "admin/ctgov_metadata/summary_cards", locals: {
              total_snapshots: @total_snapshots,
              latest_snapshot: @latest_snapshot,
              active_fields_count: @active_fields_count,
              total_fields_count: @total_fields_count
            }),
            turbo_stream.prepend("snapshots_tbody", partial: "admin/ctgov_metadata/snapshot_row", locals: {
              snapshot: @latest_snapshot
            })
          ]
        when :unchanged
          render turbo_stream: turbo_stream.replace("flash_messages", partial: "shared/flash", locals: {
            type: :info,
            message: "No changes detected - metadata is already up to date"
          })
        when :error
          render turbo_stream: turbo_stream.replace("flash_messages", partial: "shared/flash", locals: {
            type: :error,
            message: "Sync failed: #{result[:message]}"
          })
        end
      end
    end
  end

  def compare
    snapshot_ids = params[:snapshot_ids]

    # DEBUG: See what we're actually receiving
    Rails.logger.debug "🔍 Raw params: #{params.inspect}"
    Rails.logger.debug "🔍 snapshot_ids: #{snapshot_ids.inspect}"
    Rails.logger.debug "🔍 snapshot_ids.class: #{snapshot_ids.class}"
    Rails.logger.debug "🔍 snapshot_ids.size: #{snapshot_ids&.size}"

    if snapshot_ids.blank? || snapshot_ids.size != 2
      redirect_to admin_ctgov_metadata_path, alert: "Please select exactly 2 snapshots to compare"
      return
    end

    # Sort by date: oldest first (baseline), newest second (comparison)
    snapshots = [CtgovMetadataSnapshot.find(snapshot_ids.first), CtgovMetadataSnapshot.find(snapshot_ids.last)]
    sorted = snapshots.sort_by(&:created_at)
    @snapshot_a = sorted.first  # Oldest
    @snapshot_b = sorted.last   # Newest

    service = CtgovMetadataComparisonService.new(@snapshot_a, @snapshot_b)
    @comparison = service.compare
  end
end
