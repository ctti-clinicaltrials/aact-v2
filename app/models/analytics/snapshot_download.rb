module Analytics
  class SnapshotDownload < Analytics::Base
    self.table_name = "analytics_snapshot_downloads"

    SOURCES = %w[web api].freeze

    belongs_to :user
    validates :file_type, inclusion: { in: Aact::Snapshot::TYPE_MAPPING.keys }
    validates :snapshot_id, presence: true
    validates :source, inclusion: { in: SOURCES }
  end
end
