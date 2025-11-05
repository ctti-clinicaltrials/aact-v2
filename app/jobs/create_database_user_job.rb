class CreateDatabaseUserJob < ApplicationJob
  queue_as :critical

  # Don't retry if user was deleted or role doesn't exist (permanent errors)
  discard_on ActiveRecord::RecordNotFound

  # Retry on transient errors (network issues, etc.)
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(user_id)
    user = User.find(user_id)
    user.db_creation_processing!

    # delay in development to see status transitions
    sleep 5 if Rails.env.development?

    # This will either succeed (return true) or raise an exception
    AactPublic::DatabaseUser.create_user(
      user.database_username,
      user.database_password
    )

    # update status to completed if no exceptions were raised
    user.db_creation_completed!

  rescue ActiveRecord::RecordNotFound => e
    # User was deleted - nothing to do
    Rails.logger.error "User #{user_id} not found: #{e.message}"

  rescue => e
    # Any other error - mark as failed and let ActiveJob decide whether to retry
    user&.db_creation_failed!
    user&.update!(database_creation_error: e.message)
    raise # Re-raise for ActiveJob retry logic
  end
end
