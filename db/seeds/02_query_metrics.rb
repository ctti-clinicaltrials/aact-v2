# Seed aact_public_query_metrics with realistic usage data for local development.
# Uses actual database_username values from seeded users (only users with DB access).
#
# Data patterns:
#   - Weekdays have more users and queries than weekends
#   - ~20% of users are "power users" (5-10x more queries)
#   - Duration correlates with query count but has variance

puts "Seeding query metrics..."

if Rails.env.production?
  puts "  Skipping query metrics seeding in production environment."
  return
end

# Pull usernames from users who have database access
usernames = User.where.not(database_username: [ nil, "" ]).pluck(:database_username)

if usernames.empty?
  puts "  No users with database_username found. Run user seeds first."
  return
end

# Designate ~20% as power users (highest activity)
power_users = usernames.sample([ (usernames.size * 0.2).ceil, 1 ].max).to_set

end_date = Date.yesterday
start_date = end_date - 29.days

records = []

(start_date..end_date).each do |date|
  weekend = date.saturday? || date.sunday?

  # Fewer users active on weekends
  active_count = weekend ? rand(3..[usernames.size / 2, 3].max) : rand((usernames.size / 2)..usernames.size)
  active_users = usernames.sample(active_count)

  active_users.each do |username|
    base_queries = weekend ? rand(200..2_000) : rand(500..5_000)
    query_count = power_users.include?(username) ? base_queries * rand(3..8) : base_queries

    avg_ms = rand(20.0..120.0)
    total_duration = (query_count * avg_ms).round(2)

    records << {
      log_date: date,
      username: username,
      query_count: query_count,
      total_duration_ms: total_duration
    }
  end
end

AactPublicQueryMetric.upsert_all(
  records,
  unique_by: [ :log_date, :username ]
)

puts "  #{records.size} query metric records for #{usernames.size} users across #{(start_date..end_date).count} days"
