class AactPublicAnalyticsService
  def initialize(start_date: nil, end_date: nil, period: "daily")
    @start_date = start_date&.to_date || 30.days.ago.to_date
    @end_date = end_date&.to_date || Date.current
  end

  def database_usage_metrics
    {
      date_range: { start: @start_date, end: @end_date },
      metrics: AactPublicQueryMetric
        .select('log_date,
                SUM(query_count) as total_queries,
                SUM(total_duration_ms) as total_duration,
                COUNT(DISTINCT username) as unique_users')
        .where(log_date: @start_date..@end_date)
        .group(:log_date)
        .order(log_date: :desc)
        .map do |result|
          {
            date: result.log_date,
            total_queries: result.total_queries,
            total_duration_ms: result.total_duration,
            avg_query_duration_ms: safe_divide(result.total_duration, result.total_queries),
            unique_users: result.unique_users,
            queries_per_user: safe_divide(result.total_queries, result.unique_users)
          }
        end
    }
  end

  def user_usage_metrics
    {
      date_range: { start: @start_date, end: @end_date },
      users: base_query.order(log_date: :desc).map do |record|
        {
          date: record.log_date,
          username: record.username,
          query_count: record.query_count,
          total_duration_ms: record.total_duration_ms,
          avg_query_duration_ms: safe_divide(record.total_duration_ms, record.query_count)
        }
      end
    }
  end

  private

  def base_query
    @base_query ||= AactPublicQueryMetric.where(log_date: @start_date..@end_date)
  end

  def safe_divide(numerator, denominator)
    return 0 if denominator.zero?
    (numerator / denominator.to_f).round(2)
  end
end
