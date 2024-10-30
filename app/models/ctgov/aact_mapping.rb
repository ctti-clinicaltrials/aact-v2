# NOT USED FOR BUILDING DOCS FOR AACT ADMIN

module Ctgov
  class AactMapping < ApplicationRecord
    self.table_name = "ctgov.aact_mappings"

    belongs_to :api_metadata,
      foreign_key: "api_metadata_id",
      optional: true

    validates :table_name, :field_name, :api_path, presence: true
  end
end
