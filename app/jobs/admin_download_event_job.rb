class AdminDownloadEventJob < ApplicationJob
  queue_as :default

  def perform(user_id:, file_type:, snapshot_id:, source: "web", ip_address: nil, user_agent: nil)
    Analytics::SnapshotDownload.create!(
      user_id: user_id,
      file_type: file_type,
      snapshot_id: snapshot_id,
      source: source,
      ip_address: ip_address,
      user_agent: user_agent
    )
  rescue => e
    Sentry.capture_exception(e,
      tags: { feature: "admin_download_event" },
      extra: { snapshot_id: snapshot_id, source: source, user_id: user_id }
    )
    raise
  end
end
