module Aact
  class Snapshot < ApplicationRecord
    self.table_name = "support.file_records"

    # connect to aact-core database
    establish_connection :external

    TYPE_MAPPING = {
      "pgdump" => "snapshot",
      "flatfiles" => "pipefiles"
    }.freeze

    scope :latest_of_type, ->(type) {
      where(file_type: TYPE_MAPPING[type]).order(created_at: :desc).first if TYPE_MAPPING[type].present?
    }
  end
end
