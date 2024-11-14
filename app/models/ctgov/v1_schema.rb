module Ctgov
  class V1Schema< ApplicationRecord
    self.table_name = "support.ctgov_schema"

    # connect to aact-core database
    establish_connection :external
  end
end
