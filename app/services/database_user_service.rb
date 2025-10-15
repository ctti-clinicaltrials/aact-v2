class DatabaseUserService
  def self.create_user_with_database_access(params)
    ActiveRecord::Base.transaction do
      # Create user in primary database
      user = User.new(params)
      user.save!

      # Public DB operations are not in this transaction (separate connection)
      password = params[:password]
      username = params[:username]
      success = AactPublic::DatabaseUser.create_user(username, password)

      unless success
        raise ActiveRecord::Rollback, "Failed to create database user"
      end

      user
    end
  end
end
