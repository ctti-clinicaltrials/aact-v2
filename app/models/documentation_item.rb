class DocumentationItem < ApplicationRecord
  CACHE_KEY_TABLE_NAMES = "documentation_table_names".freeze

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

  # Get unique table names for dropdown (cached)
  def self.table_names
    Rails.cache.fetch(CACHE_KEY_TABLE_NAMES) do
      distinct.order(:table_name).pluck(:table_name)
    end
  end

  def self.clear_table_names_cache
    Rails.cache.delete(CACHE_KEY_TABLE_NAMES)
  end
end
