class DocumentationItem < ApplicationRecord
  scope :search, ->(term) {
    return all if term.blank?
    where(
      "table_name ILIKE :q OR column_name ILIKE :q OR description ILIKE :q
       OR ctgov_name ILIKE :q OR ctgov_label ILIKE :q OR ctgov_path ILIKE :q",
      q: "%#{term}%"
    )
  }

  scope :by_table, ->(table) { where(table_name: table) if table.present? }
  scope :by_active, ->(active) { where(active: active) unless active.nil? }

  # Get unique table names for dropdown
  def self.table_names
    distinct.order(:table_name).pluck(:table_name)
  end
end
