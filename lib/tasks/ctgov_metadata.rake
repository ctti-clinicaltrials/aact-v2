namespace :ctgov do
  namespace :metadata do
    desc "Sync CTGov metadata from API"
    task sync: :environment do
      puts "🔄 Syncing CTGov metadata from API..."
      service = CtgovMetadataSyncService.new(api_version: "2", source: :api)
      result = service.sync

      case result[:status]
      when :success
        puts "✅ Success!"
        puts "   Snapshot ID: #{result[:snapshot_id]}"
        puts "   Fields synced: #{result[:field_count]}"
      when :unchanged
        puts "ℹ️  #{result[:message]}"
      when :error
        puts "❌ Error: #{result[:message]}"
        exit 1
      end
    end

    desc "Sync CTGov metadata from local file (for testing)"
    task sync_from_file: :environment do
      puts "🔄 Syncing CTGov metadata from local file..."
      service = CtgovMetadataSyncService.new(api_version: "2", source: :file)
      result = service.sync

      case result[:status]
      when :success
        puts "✅ Success!"
        puts "   Snapshot ID: #{result[:snapshot_id]}"
        puts "   Fields synced: #{result[:field_count]}"
      when :unchanged
        puts "ℹ️  #{result[:message]}"
      when :error
        puts "❌ Error: #{result[:message]}"
        exit 1
      end
    end

    desc "Test flattening logic with sample data"
    task test_flatten: :environment do
      # Sample nested structure
      sample_json = [
        {
          "name" => "protocolSection",
          "piece" => "ProtocolSection",
          "title" => "Study Protocol",
          "sourceType" => "STRUCT",
          "type" => "ProtocolSection",
          "children" => [
            {
              "name" => "identificationModule",
              "piece" => "IdentificationModule",
              "sourceType" => "STRUCT",
              "children" => [
                {
                  "name" => "nctId",
                  "piece" => "NCTId",
                  "title" => "NCT Number",
                  "sourceType" => "TEXT",
                  "type" => "nct",
                  "maxChars" => 20,
                  "synonyms" => true,
                  "altPieceNames" => [ "NCT-ID", "NCT ID" ],
                  "dedLink" => {
                    "label" => "Study Identification",
                    "url" => "https://clinicaltrials.gov/policy/protocol-definitions#NCTId"
                  }
                }
              ]
            }
          ]
        }
      ]

      puts "Testing flattening with sample data..."
      flattener = CtgovMetadataFlattener.new(sample_json, api_version: "2")
      result = flattener.flatten

      puts "\n✅ Flattened #{result.size} records:"
      result.each do |record|
        puts "\n  Path: #{record[:path]}"
        puts "  Name: #{record[:name]}"
        puts "  Piece: #{record[:piece]}"
        puts "  Title: #{record[:title]}"
        puts "  Source Type: #{record[:source_type]}"
        puts "  Type: #{record[:type]}"
        puts "  Alt Names: #{record[:alt_piece_names].inspect}"
        puts "  Link: #{record[:ded_link_url]}"
      end
    end

    desc "Refresh documentation items (sync from core + local metadata)"
    task refresh_docs: :environment do
      puts "🔄 Refreshing documentation items..."
      SyncDocumentationJob.perform_now
      puts "✅ Complete! DocumentationItem records: #{DocumentationItem.count}"
    end

    desc "Show current metadata stats"
    task stats: :environment do
      puts "📊 CTGov Metadata Statistics"
      puts "=" * 50
      puts "Snapshots: #{CtgovMetadataSnapshot.count}"
      puts "Latest snapshot: #{CtgovMetadataSnapshot.recent.first&.created_at || 'None'}"
      puts ""
      puts "Metadata records: #{CtgovMetadata.count}"
      puts "  Active: #{CtgovMetadata.active.count}"
      puts "  Inactive: #{CtgovMetadata.inactive.count}"
      puts ""
      puts "By source type:"
      CtgovMetadata.active.group(:source_type).count.each do |type, count|
        puts "  #{type}: #{count}"
      end
    end
  end
end
