module Ctgov
  class V1Mapping < ApplicationRecord
    self.table_name = "support.ctgov_mapping"

    # connect to aact-core database
    establish_connection :external

    scope :active, -> { where(active: true) }
  end
end
