class SnapshotDownloadsAnalyticsService
  LEGACY_USER_EMAIL = "legacy@aact.system"

  def initialize(start_date: nil, end_date: nil)
    @start_date = start_date&.to_date || 9.days.ago.to_date
    @end_date = end_date&.to_date || Date.current
  end

  def daily_metrics
    legacy_id = User.find_by(email_address: LEGACY_USER_EMAIL)&.id.to_i

    rows = Analytics::SnapshotDownload
      .where(file_type: %w[flatfiles pgdump])
      .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
      .group("DATE(created_at)")
      .order(Arel.sql("DATE(created_at) DESC"))
      .pluck(Arel.sql(<<~SQL))
        DATE(created_at) AS day,
        COUNT(*) AS total,
        COUNT(*) FILTER (WHERE user_id <> #{legacy_id}) AS authenticated,
        COUNT(*) FILTER (WHERE source = 'web' AND file_type = 'flatfiles') AS web_flatfiles,
        COUNT(*) FILTER (WHERE source = 'web' AND file_type = 'pgdump')    AS web_pgdump,
        COUNT(*) FILTER (WHERE source = 'api' AND file_type = 'flatfiles') AS api_flatfiles,
        COUNT(*) FILTER (WHERE source = 'api' AND file_type = 'pgdump')    AS api_pgdump
      SQL

    {
      date_range: { start: @start_date, end: @end_date },
      metrics: rows.map do |day, total, authenticated, web_flat, web_pg, api_flat, api_pg|
        {
          date: day.to_date,
          total: total,
          authenticated: authenticated,
          web_flatfiles: web_flat,
          web_pgdump: web_pg,
          api_flatfiles: api_flat,
          api_pgdump: api_pg
        }
      end
    }
  end
end
