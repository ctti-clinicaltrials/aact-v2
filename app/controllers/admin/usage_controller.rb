class Admin::UsageController < Admin::BaseController
  DATA_COLLECTION_START = Date.new(2025, 6, 6)

  def index
    @end_date = parse_date(params[:end_date], Date.yesterday)
    @start_date = parse_date(params[:start_date], @end_date - 9.days)

    service = AactPublicAnalyticsService.new(start_date: @start_date, end_date: @end_date)
    result = service.database_usage_metrics
    @metrics = result[:metrics]

    compute_summary_stats
  end

  def show
    @date = parse_date(params[:date], Date.yesterday)
    @formatted_date = @date.strftime("%B %d, %Y")
    @pgbadger_url = "#{ENV.fetch('BASE_PGBADGER_URL', 'https://ctti-aact.nyc3.digitaloceanspaces.com/pgbadger/html')}/#{@date.strftime('%Y-%m-%d')}.html"

    service = AactPublicAnalyticsService.new(start_date: @date, end_date: @date)
    result = service.user_usage_metrics
    @users = result[:users].sort_by { |u| -u[:query_count] }

    @stats = {
      total_users: @users.size,
      total_queries: @users.sum { |u| u[:query_count] },
      total_duration: @users.sum { |u| u[:total_duration_ms] }
    }
    @stats[:avg_queries_per_user] = @stats[:total_users].positive? ? @stats[:total_queries].to_f / @stats[:total_users] : 0

    usernames = @users.map { |u| u[:username] }
    @user_map = User.where(database_username: usernames).index_by(&:database_username)
  end

  private

  def parse_date(value, fallback)
    value.present? ? Date.parse(value) : fallback
  rescue Date::Error
    fallback
  end

  def compute_summary_stats
    return if @metrics.blank?

    users = @metrics.map { |m| m[:unique_users] }
    @avg_users = (users.sum.to_f / users.size).round
    @max_users = users.max
    @min_users = users.min
    @total_queries = @metrics.sum { |m| m[:total_queries] }
    @avg_queries_per_day = (@total_queries.to_f / @metrics.size).round
    @avg_duration = (@metrics.sum { |m| m[:avg_query_duration_ms] } / @metrics.size).round
  end
end
