# NOT USED FOR BUILDING DOCS FOR AACT ADMIN

module Ctgov
  class ApiMetadata < ApplicationRecord
    self.table_name = "ctgov.api_metadata"

    # TODO: Add active flag - to handle changes coming from the API

    has_many :aact_mappings,
      foreign_key: "api_metadata_id"

    validates :name, :data_type, :path, :version, presence: true
  end
end
