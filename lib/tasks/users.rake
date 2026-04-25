namespace :users do
  desc "Test connection to aact-admin database"
  task test_admin_connection: :environment do
    url = ENV.fetch("AACT_ADMIN_DB_URL") { abort "AACT_ADMIN_DB_URL is not set" }

    conn = PG.connect(url)
    count = conn.exec("SELECT COUNT(*) FROM ctgov.users").first["count"]
    puts "Connected to aact-admin. Found #{count} users in ctgov.users."
  ensure
    conn&.close
  end
end
