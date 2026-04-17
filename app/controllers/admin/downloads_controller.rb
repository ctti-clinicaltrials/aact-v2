class Admin::DownloadsController < Admin::BaseController
  def index
    @end_date = parse_date(params[:end_date], Date.current)
    @start_date = parse_date(params[:start_date], @end_date - 9.days)

    service = SnapshotDownloadsAnalyticsService.new(start_date: @start_date, end_date: @end_date)
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
    @avg_downloads = (totals.sum.to_f / totals.size).round
    @max_downloads = totals.max
    @min_downloads = totals.min
    @total_downloads = totals.sum
    @total_authenticated = @metrics.sum { |m| m[:authenticated] }
    @authenticated_share = @total_downloads.positive? ? (@total_authenticated.to_f / @total_downloads * 100).round(1) : 0
  end
end
