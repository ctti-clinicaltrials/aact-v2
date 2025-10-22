class DatabaseUserService
  # Legacy method for backward compatibility (deprecated)
  def self.create_user_with_database_access(params)
    ActiveRecord::Base.transaction do
      # Create user in primary database
      user = User.new(params)
      user.save!

      # Public DB operations are not in this transaction (separate connection)
      password = params[:password]
      # Use email_address as username for database access
      username = params[:email_address]
      success = AactPublic::DatabaseUser.create_user(username, password)

      unless success
        raise ActiveRecord::Rollback, "Failed to create database user"
      end

      user
    end
  end

  # New Step 2 method: Create database user with provided credentials
  def self.create_database_user(username:, password:)
    begin
      success = AactPublic::DatabaseUser.create_user(username, password)

      if success
        { success: true, username: username }
      else
        { success: false, error: "Failed to create database user" }
      end
    rescue StandardError => e
      Rails.logger.error "DatabaseUserService error: #{e.message}"
      { success: false, error: e.message }
    end
  end
end
