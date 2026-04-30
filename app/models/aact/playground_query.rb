module Aact
  class PlaygroundQuery < ApplicationRecord
    self.table_name = "public.background_jobs"
    self.inheritance_column = :_type_disabled

    establish_connection :external

    DB_QUERY_TYPE = "BackgroundJob::DbQuery".freeze
    default_scope { where(type: DB_QUERY_TYPE) }
  end
end
