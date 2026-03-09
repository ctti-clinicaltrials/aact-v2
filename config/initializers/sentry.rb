# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.debug = Rails.env.development?

  # Which environment label shows up in the Sentry dashboard.
  # Reads SENTRY_ENVIRONMENT env var if set; falls back to Rails.env.
  config.environment = ENV.fetch("SENTRY_ENVIRONMENT", Rails.env)

  # Only send events in these environments.
  # To test locally: set SENTRY_ENVIRONMENT=staging in .env and add "staging" here,
  # or temporarily add "development".
  config.enabled_environments = %w[production staging]

  # Breadcrumbs from Rails instrumentation (SQL queries, cache, outbound HTTP).
  config.breadcrumbs_logger = [ :active_support_logger, :http_logger ]

  # Performance tracing: % of requests that get full timing traces.
  # Separate from error tracking — errors are always captured regardless.
  # 1.0 = 100% (fine for low traffic), 0.1 is typical for production at scale.
  config.traces_sample_rate = ENV.fetch("SENTRY_TRACES_SAMPLE_RATE", "0.1").to_f

  # Includes request headers and user IP in error reports. Keep false unless needed.
  config.send_default_pii = false

  # Only report Sidekiq job errors after all retries exhausted, not on every attempt.
  # Default is false (reports on every attempt, which is noisy for high-retry jobs).
  config.sidekiq.report_after_job_retries = true
end
