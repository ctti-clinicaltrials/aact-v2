class Admin::PlaygroundController < Admin::BaseController
  def index
    @end_date = parse_date(params[:end_date], Date.current)
    @start_date = parse_date(params[:start_date], @end_date - 9.days)

    service = PlaygroundAnalyticsService.new(start_date: @start_date, end_date: @end_date)
    result = service.daily_metrics
    @metrics = result[:metrics]

    compute_summary_stats
  end

  private

  def parse_date(value, fallback)
    value.present? ? Date.parse(value) : fallback
  rescue Date::Error
    fallback
  end

  def compute_summary_stats
    return if @metrics.blank?

    totals = @metrics.map { |m| m[:total] }
    @total_queries = totals.sum
    @avg_queries_per_day = (@total_queries.to_f / totals.size).round
    @max_queries_per_day = totals.max

    @total_completed = @metrics.sum { |m| m[:completed] }
    @total_errors = @metrics.sum { |m| m[:errors] }
    @completion_rate = @total_queries.positive? ? (@total_completed.to_f / @total_queries * 100).round(1) : 0

    users = @metrics.map { |m| m[:unique_users] }
    @avg_users_per_day = (users.sum.to_f / users.size).round
  end
end
