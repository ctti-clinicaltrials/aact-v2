module AactPublic
  class Base < ApplicationRecord
    establish_connection :public_database
    self.abstract_class = true

    # Base class for all public database operations
    def self.database_accessible?
      connection.execute("SELECT 1").count == 1
    rescue StandardError
      false
    end
  end
end
