module Ctgov
  class V1ApiMetadata < ApplicationRecord
    self.table_name = "support.ctgov_metadata"

    # connect to aact-core database
    establish_connection :external

    scope :version_2, -> { where(version: 2) }
  end
end
