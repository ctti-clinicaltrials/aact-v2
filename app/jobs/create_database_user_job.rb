class CreateDatabaseUserJob < ApplicationJob
  queue_as :critical

  # Don't retry if user was deleted or role doesn't exist (permanent errors)
  discard_on ActiveRecord::RecordNotFound

  # Retry on transient errors (network issues, etc.)
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(user_id)
    user = User.find(user_id)
    user.db_creation_processing!
    broadcast_status_update(user, :processing)

    # delay in development to see status transitions
    sleep 5 if Rails.env.development?

    # This will either succeed (return true) or raise an exception
    AactPublic::DatabaseUser.create_user(
      user.database_username,
      user.database_password
    )

    # update status to completed if no exceptions were raised
    user.db_creation_completed!
    broadcast_status_update(user, :completed)

  rescue ActiveRecord::RecordNotFound => e
    # User was deleted - nothing to do
    Rails.logger.error "User #{user_id} not found: #{e.message}"

  rescue => e
    # Any other error - mark as failed and let ActiveJob decide whether to retry
    user&.db_creation_failed!
    user&.update!(database_creation_error: e.message)
    broadcast_status_update(user, :failed) if user
    raise # Re-raise for ActiveJob retry logic
  end

  private

  def broadcast_status_update(user, status)
    case status
    when :processing
      Turbo::StreamsChannel.broadcast_replace_to(
        "user_#{user.id}_database_setup",
        target: "database_status",
        partial: "settings/database_accesses/processing_status"
      )
    when :completed
      # Replace the entire frame with credentials to clean up stream subscription
      Turbo::StreamsChannel.broadcast_replace_to(
        "user_#{user.id}_database_setup",
        target: "database_setup",
        partial: "settings/database_accesses/credentials",
        locals: { user: user }
      )
    when :failed
      Turbo::StreamsChannel.broadcast_replace_to(
        "user_#{user.id}_database_setup",
        target: "database_status",
        partial: "settings/database_accesses/error_status",
        locals: { user: user }
      )
    end
  end
end
