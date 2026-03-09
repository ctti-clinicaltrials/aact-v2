class SentryTestJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2

  def perform
    raise "Sentry retry test - intentional failure"
  end
end
