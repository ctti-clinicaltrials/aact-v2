class PlaygroundAnalyticsService
  def initialize(start_date: nil, end_date: nil)
    @start_date = start_date&.to_date || 9.days.ago.to_date
    @end_date = end_date&.to_date || Date.current
  end

  def daily_metrics
    rows = Aact::PlaygroundQuery
      .where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
      .group("DATE(created_at)")
      .order(Arel.sql("DATE(created_at) DESC"))
      .pluck(Arel.sql(<<~SQL))
        DATE(created_at) AS day,
        COUNT(*) AS total,
        COUNT(DISTINCT user_id) AS unique_users,
        COUNT(*) FILTER (WHERE status = 'complete') AS completed,
        COUNT(*) FILTER (WHERE status = 'error')    AS errors
      SQL

    {
      date_range: { start: @start_date, end: @end_date },
      metrics: rows.map do |day, total, unique_users, completed, errors|
        {
          date: day.to_date,
          total: total,
          unique_users: unique_users,
          completed: completed,
          errors: errors
        }
      end
    }
  end
end
