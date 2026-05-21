module Aact
  class EtlJob < ApplicationRecord
    self.table_name = "support.etl_jobs"
    self.inheritance_column = nil  # disable STI on v2 — type is a plain string

    # connect to aact-core database
    establish_connection :external
  end
end
