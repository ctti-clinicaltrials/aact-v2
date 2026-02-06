module Aact
  class Snapshot < ApplicationRecord
    self.table_name = "support.file_records"

    # connect to aact-core database
    establish_connection :external

    TYPE_MAPPING = {
      "pgdump" => "snapshot",
      "flatfiles" => "pipefiles",
      "covid" => "covid-19"
    }.freeze

    def self.latest_of_type(type)
      return nil unless TYPE_MAPPING[type].present?

      where(file_type: TYPE_MAPPING[type])
        .order(created_at: :desc)
        .first
    end
  end
end
