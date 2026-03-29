namespace :analytics do
  desc "Import historical download events from aact-admin file_downloads table"
  task import_admin_downloads: :environment do
    legacy_user_id = User.find_by!(email_address: "legacy@aact.system").id
    admin_conn = PG.connect(ENV.fetch("AACT_ADMIN_DB_URL") { abort "AACT_ADMIN_DB_URL is not set" })

    batch_size = 1_000
    last_id = 0
    total_imported = 0
    total_skipped = 0

    loop do
      rows = admin_conn.exec_params(
        "SELECT id, file_record_id, created_at FROM file_downloads WHERE id > $1 ORDER BY id LIMIT $2",
        [ last_id, batch_size ]
      )
      break if rows.ntuples == 0

      snapshot_ids = rows.map { |r| r["file_record_id"].to_i }.uniq
      snapshots_by_id = Aact::Snapshot.where(id: snapshot_ids).index_by(&:id)

      records = rows.filter_map do |row|
        snapshot = snapshots_by_id[row["file_record_id"].to_i]
        api_type = snapshot&.api_type

        unless snapshot && api_type
          total_skipped += 1
          next
        end

        now = row["created_at"]
        {
          user_id: legacy_user_id,
          file_type: api_type,
          snapshot_id: row["file_record_id"],
          source: "api",
          ip_address: nil,
          user_agent: nil,
          created_at: now,
          updated_at: now
        }
      end

      Analytics::SnapshotDownload.insert_all(records, record_timestamps: false) if records.any?

      total_imported += records.size
      last_id = rows[rows.ntuples - 1]["id"].to_i
      print "."
      $stdout.flush
    end

    admin_conn.close
    puts "\nDone. Imported: #{total_imported}, Skipped: #{total_skipped}"
  end
end
