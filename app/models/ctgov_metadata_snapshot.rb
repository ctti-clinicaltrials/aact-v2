class CtgovMetadataSnapshot < ApplicationRecord
  self.table_name = "snapshots.ctgov_metadata"

  # Validations
  validates :api_version, presence: true
  validates :snapshot, presence: true

  # Scopes
  scope :by_version, ->(version) { where(api_version: version) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_save :set_field_count, if: -> { field_count.nil? }
  before_save :set_checksum, if: -> { checksum.nil? }

  # Class methods
  def self.latest(api_version = "2")
    by_version(api_version).recent.first
  end

  def self.has_changed?(new_snapshot, api_version = "2")
    latest_snapshot = latest(api_version)
    return true if latest_snapshot.nil?

    new_checksum = Digest::SHA256.hexdigest(new_snapshot.to_json)
    latest_snapshot.checksum != new_checksum
  end

  # Instance methods
  def generate_checksum
    Digest::SHA256.hexdigest(snapshot.to_json)
  end

  def count_leaf_nodes
    count_nodes(snapshot)
  end

  private

  def set_checksum
    self.checksum = generate_checksum
  end

  def set_field_count
    self.field_count = count_leaf_nodes
  end

  def count_nodes(node)
    return 0 if node.nil?

    if node.is_a?(Array)
      node.sum { |child| count_nodes(child) }
    elsif node.is_a?(Hash) && node["children"]
      node["children"].sum { |child| count_nodes(child) }
    elsif node.is_a?(Hash) && !node["children"]
      1 # Leaf node
    else
      0
    end
  end
end
