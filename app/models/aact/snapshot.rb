module Aact
  class Snapshot < ApplicationRecord
    self.table_name = "support.file_records"

    # connect to aact-core database
    establish_connection :external

    TYPE_MAPPING = {
      "pgdump"   => "snapshot",
      "flatfiles" => "pipefiles",
      "covid"    => "covid-19"
    }.freeze

    REVERSE_TYPE_MAPPING = TYPE_MAPPING.invert.freeze

    scope :of_type, ->(type) { where(file_type: TYPE_MAPPING[type]) if TYPE_MAPPING[type] }
    scope :recent,  -> { order(created_at: :desc).limit(30) }
    scope :ordered, -> { order(created_at: :desc) }

    def self.latest_of_type(type)
      return nil unless TYPE_MAPPING[type].present?

      of_type(type).ordered.first
    end

    def api_type
      REVERSE_TYPE_MAPPING[file_type]
    end

    def formatted_date
      created_at.strftime("%B %-d, %Y")
    end

    def formatted_size
      return "Unknown" if file_size.nil?
      return "#{file_size} B" if file_size < 1024

      units = [ "B", "KB", "MB", "GB", "TB" ]
      size = file_size.to_f
      unit_index = 0

      while size >= 1024 && unit_index < units.length - 1
        size /= 1024
        unit_index += 1
      end

      "#{size.round(1)} #{units[unit_index]}"
    end
  end
end
