module Analytics
  class SnapshotDownload < Analytics::Base
    self.table_name = "analytics_snapshot_downloads"

    belongs_to :user
    validates :file_type, inclusion: { in: Aact::Snapshot::TYPE_MAPPING.keys }
    validates :snapshot_id, presence: true
  end
end
