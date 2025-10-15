module AactPublic
  class DatabaseUser < Base
    # Inherits public_database connection

    def self.user_exists?(username)
      result = connection.execute(
        "SELECT 1 FROM pg_catalog.pg_user WHERE usename = #{connection.quote(username)}"
      )
      result.count > 0
    end

    # Create PostgreSQL user with role-based access
    # This method assumes a 'read_only' role already exists in the database
    def self.create_user(username, password)
      # Check if user already exists
      if user_exists?(username)
        Rails.logger.info "Database user #{username} already exists"
        return true
      end

      # Create PostgreSQL user with LOGIN capability
      connection.execute(
        "CREATE USER #{connection.quote_column_name(username)} " \
        "WITH PASSWORD #{connection.quote(password)} LOGIN"
      )

      # Grant existing read_only role (must exist)
      connection.execute(
        "GRANT read_only TO #{connection.quote_column_name(username)}"
      )

      # Set search path (replicates admin behavior)
      connection.execute(
        "ALTER ROLE #{connection.quote_column_name(username)} " \
        "IN DATABASE #{connection.current_database} SET search_path = ctgov, mesh_archive"
      )

      Rails.logger.info "Created database user #{username} with read_only role access"
      true
    rescue PG::UndefinedObject => e
      if e.message.include?("role") && e.message.include?("read_only")
        Rails.logger.error "read_only role does not exist in public database"
        raise "read_only role does not exist in public database. Please set it up first."
      end
      raise
    rescue => e
      Rails.logger.error "Failed to create database user: #{e.message}"
      false
    end
  end
end
