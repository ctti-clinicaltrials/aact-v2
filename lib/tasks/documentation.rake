namespace :documentation do
  desc "Sync documentation from external database (truncate + insert)"
  task sync: :environment do
    puts "Syncing documentation..."
    SyncDocumentationJob.perform_now
    puts "Done! #{DocumentationItem.count} records synced."
  end
end
