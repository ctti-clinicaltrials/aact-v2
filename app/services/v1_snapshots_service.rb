# require "ostruct"
class V1SnapshotsService
  SNAPSHOT_TYPES = [ "pgdump", "flatfiles" ].freeze

  def initialize
    load_latest_snapshots
  end

  def latest
    SNAPSHOT_TYPES.map do |type|
      snapshot = @latest_snapshots[type]
      next unless snapshot

      {
        type: type,
        date: snapshot.created_at&.strftime("%Y-%m-%d"),
        file_name: snapshot.filename,
        download_url: snapshot.url,
        size: format_size(snapshot.file_size)
      }
    end.compact
  end

  private

  def load_latest_snapshots
    @latest_snapshots = {}
    SNAPSHOT_TYPES.each do |type|
      @latest_snapshots[type] = Aact::Snapshot.latest_of_type(type)
    end
  end

  def format_size(bytes)
    return "#{bytes} B" if bytes.nil? || bytes < 1024

    units = [ "B", "KB", "MB", "GB", "TB" ]
    size = bytes.to_f
    unit_index = 0

    while size >= 1024 && unit_index < units.length - 1
      size /= 1024
      unit_index += 1
    end

    "#{size.round(2)} #{units[unit_index]}"
  end
end
