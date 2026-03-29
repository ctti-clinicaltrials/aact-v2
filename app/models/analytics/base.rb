module Analytics
  class Base < ApplicationRecord
    self.abstract_class = true


    # shared scopes (by_user, by_date, this_week) go here as analytics models are added
  end
end
