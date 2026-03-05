require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Aact
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Ensure workers are autoloaded (for Sidekiq)
    # config.autoload_paths += %W[#{config.root}/app/workers]

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Use SQL schema format for PostgreSQL
    config.active_record.schema_format = :sql

    # Enable CSRF protection by default for all controllers
    config.action_controller.default_protect_from_forgery = true
    config.action_controller.forgery_protection_strategy = :exception

    # Configure ActiveJob to use Sidekiq
    config.active_job.queue_adapter = :sidekiq
  end
end
