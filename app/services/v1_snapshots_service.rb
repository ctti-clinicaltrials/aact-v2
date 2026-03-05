class V1SnapshotsService
  SNAPSHOT_TYPES = [ "pgdump", "flatfiles", "covid" ].freeze

  def latest
    SNAPSHOT_TYPES.map do |type|
      snapshot = latest_snapshot_of_type(type)
      next unless snapshot

      {
        type: type,
        date: snapshot.created_at&.strftime("%m-%d-%Y"),
        file_name: snapshot.filename,
        download_url: snapshot.url,
        size: format_size(snapshot.file_size)
      }
    end.compact
  end

  def get_snapshots(type = nil)
    if type.present? && !SNAPSHOT_TYPES.include?(type)
      return { error: "Invalid snapshot type. Available types: #{SNAPSHOT_TYPES.join(', ')}" }
    end

    types_to_fetch = type.present? ? [ type ] : SNAPSHOT_TYPES
    result = {}

    types_to_fetch.each do |snapshot_type|
      result[snapshot_type] = fetch_all_snapshots_by_type(snapshot_type)
    end

    result
  end

  private

  def latest_snapshot_of_type(type)
    Aact::Snapshot.latest_of_type(type)
  end

  def fetch_all_snapshots_by_type(type)
    db_type = Aact::Snapshot::TYPE_MAPPING[type]
    return { daily: [], monthly: {} } unless db_type.present?

    {
      daily: fetch_daily_snapshots(db_type),
      monthly: fetch_monthly_snapshots_by_year(db_type)
    }
  end

  def fetch_daily_snapshots(db_type)
    # Get the most recent 30 snapshots
    records = Aact::Snapshot.where(file_type: db_type)
                           .order(created_at: :desc)
                           .limit(30)

    api_type = SNAPSHOT_TYPES.find { |t| Aact::Snapshot::TYPE_MAPPING[t] == db_type }

    records.map do |record|
      {
        type: api_type,
        date: record.created_at.strftime("%m-%d-%Y"),
        file_name: record.filename,
        download_url: record.url,
        size: format_size(record.file_size)
      }
    end
  end

  def fetch_monthly_snapshots_by_year(db_type)
    records = Aact::Snapshot.where(file_type: db_type).order(created_at: :asc)

    api_type = SNAPSHOT_TYPES.find { |t| Aact::Snapshot::TYPE_MAPPING[t] == db_type }

    # Group by month and select the 1st day snapshot (or earliest if none)
    monthly_by_year = {}

    records.group_by { |r| r.created_at.strftime("%Y-%m") }.each do |month_key, month_records|
      # Prefer snapshot from the 1st day of the month, fallback to earliest
      target_record = month_records.find { |r| r.created_at.day == 1 } || month_records.first

      year = target_record.created_at.year.to_s

      monthly_by_year[year] ||= []
      monthly_by_year[year] << {
        type: api_type,
        date: target_record.created_at.strftime("%m-%d-%Y"),
        file_name: target_record.filename,
        download_url: target_record.url,
        size: format_size(target_record.file_size)
      }
    end

    monthly_by_year
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
