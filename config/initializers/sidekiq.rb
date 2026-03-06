redis_config = {
  url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0"),
  ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
}

Sidekiq.configure_server do |config|
  config.redis = redis_config

  schedule_file = Rails.root.join("config/sidekiq_schedule.yml")
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash(YAML.load_file(schedule_file))
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
