class SnapshotsService
  TYPES = Aact::Snapshot::TYPE_MAPPING.keys.freeze

  # Returns the latest snapshot for each type.
  # Used by the downloads index page.
  def latest
    TYPES.filter_map { |type| Aact::Snapshot.latest_of_type(type) }
  end

  # Returns an AR relation of the 30 most recent snapshots for a type.
  # Passed directly to Pagy for pagination.
  def daily(type)
    Aact::Snapshot.of_type(type).recent
  end

  # Returns snapshots grouped by year, one per month.
  # Prefers a snapshot from the 1st of the month; falls back to earliest that month.
  # { "2025" => [snapshot, ...], "2024" => [snapshot, ...] }
  def monthly(type)
    records = Aact::Snapshot.of_type(type).ordered

    records
      .group_by { |r| r.created_at.strftime("%Y-%m") }
      .each_with_object({}) do |(month_key, month_records), result|
        record = month_records.find { |r| r.created_at.day == 1 } || month_records.last
        year   = record.created_at.year.to_s
        result[year] ||= []
        result[year] << record
      end
  end
end
