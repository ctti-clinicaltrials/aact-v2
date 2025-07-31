class AactPublicAnalyticsService
  def initialize(start_date: nil, end_date: nil, period: "daily")
    @start_date = start_date&.to_date || 30.days.ago.to_date
    @end_date = end_date&.to_date || Date.current
  end

  def database_usage_metrics
    puts base_query.order(:log_date).group_by { |record| record.log_date }.inspect
    {
      date_range: { start: @start_date, end: @end_date },
      metrics: base_query.order(:log_date).group_by(&:log_date).map do |date, records|
        {
          date: date,
          total_queries: records.sum(&:query_count),
          total_duration_ms: records.sum(&:total_duration_ms),
          avg_query_duration_ms: safe_divide(records.sum(&:total_duration_ms), records.sum(&:query_count)),
          unique_users: records.map(&:username).uniq.count,
          queries_per_user: safe_divide(records.sum(&:query_count), records.map(&:username).uniq.count)
        }
      end
    }
  end

  def user_usage_metrics
    {
      date_range: { start: @start_date, end: @end_date },
      users: base_query.order(:log_date).group_by(&:log_date).flat_map do |date, records|
        user_groups = records.group_by(&:username)
        user_groups.map do |username, user_records|
          {
            date: date,
            username: username,
            query_count: user_records.sum(&:query_count),
            total_duration_ms: user_records.sum(&:total_duration_ms),
            avg_query_duration_ms: safe_divide(user_records.sum(&:total_duration_ms), user_records.sum(&:query_count)),
            active_days: user_records.map(&:log_date).uniq.count
          }
        end
      end
    }
  end

  private

  def base_query
    @base_query ||= AactPublicQueryMetric.where(log_date: @start_date..@end_date)
  end

  # TODO: make a utility method + add rounding options
  def safe_divide(numerator, denominator)
    return 0 if denominator.zero?
    (numerator / denominator.to_f).round(2)
  end
end
