class CtgovMetadata < ApplicationRecord
  # Disable Single Table Inheritance (type column is for CTGov data, not Rails STI)
  self.inheritance_column = nil

  # Validations
  validates :path, presence: true, uniqueness: true
  validates :name, presence: true
  validates :source_type, presence: true
  validates :api_version, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_version, ->(version) { where(api_version: version) }
  scope :by_source_type, ->(type) { where(source_type: type) }
  scope :enums, -> { where(is_enum: true) }
  scope :with_synonyms, -> { where(synonyms: true) }
  scope :search, ->(query) do
    where("name ILIKE ? OR piece ILIKE ? OR title ILIKE ? OR description ILIKE ?",
          "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
  end

  # Class methods
  def self.text_fields
    by_source_type("TEXT")
  end

  def self.struct_fields
    by_source_type("STRUCT")
  end

  def self.by_section(section_name)
    where("path LIKE ?", "#{section_name}.%")
  end

  # Instance methods
  def array?
    type&.end_with?("[]")
  end

  def section
    path.split(".").first
  end

  def module_name
    parts = path.split(".")
    parts[1] if parts.length > 1
  end

  def parent_path
    parts = path.split(".")
    parts[0...-1].join(".") if parts.length > 1
  end

  def has_alternatives?
    synonyms && alt_piece_names.present?
  end

  def alternative_names
    alt_piece_names || []
  end
end
