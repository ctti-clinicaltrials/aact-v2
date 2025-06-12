class AactPublicQueryMetric < ApplicationRecord
  validates :log_date, presence: true
  validates :username, presence: true
  validates :query_count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :total_duration_ms, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # match db constraint
  validates :username, uniqueness: { scope: :log_date }
end
