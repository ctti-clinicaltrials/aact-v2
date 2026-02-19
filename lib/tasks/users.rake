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

  desc "Migrate users from aact-admin to aact-v2 (upsert by email)"
  task migrate_from_admin: :environment do
    url = ENV.fetch("AACT_ADMIN_DB_URL") { abort "AACT_ADMIN_DB_URL is not set" }

    conn = PG.connect(url)

    rows = conn.exec(<<~SQL)
      SELECT email, encrypted_password, first_name, last_name, username, admin,
             confirmed_at, sign_in_count, current_sign_in_at, last_sign_in_at,
             current_sign_in_ip, last_sign_in_ip, db_activity, last_db_activity,
             created_at
      FROM ctgov.users
    SQL

    source_count = rows.ntuples
    created = 0
    updated = 0
    errors = []

    User.record_timestamps = false

    rows.each_with_index do |row, index|
      email = row["email"].to_s.strip.downcase
      if email.blank?
        errors << "row #{index + 1}: (blank email) — Email can't be blank"
        next
      end

      first = row["first_name"].to_s.strip
      last = row["last_name"].to_s.strip
      name = "#{first} #{last}".strip
      name = email.split("@").first if name.blank?

      username = row["username"].to_s.strip.presence

      metadata = {
        first_name: first.presence,
        last_name: last.presence,
        admin: row["admin"],
        confirmed_at: row["confirmed_at"],
        sign_in_count: row["sign_in_count"],
        current_sign_in_at: row["current_sign_in_at"],
        last_sign_in_at: row["last_sign_in_at"],
        current_sign_in_ip: row["current_sign_in_ip"],
        last_sign_in_ip: row["last_sign_in_ip"],
        db_activity: row["db_activity"],
        last_db_activity: row["last_db_activity"]
      }.compact

      user = User.find_by(email_address: email)
      is_new = user.nil?
      user ||= User.new(email_address: email)

      user.name = name
      user.database_username = username
      user.migrated = true
      user.metadata = metadata
      user.password_digest = row["encrypted_password"]
      user.created_at = row["created_at"]

      user.save!

      is_new ? created += 1 : updated += 1
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
      errors << "row #{index + 1}: #{email} — #{e.message}"
    end

    User.record_timestamps = true
    conn.close

    puts <<~SUMMARY

      === Migration Summary ===
      Source (aact-admin):  #{source_count} users
      Created:              #{created}
      Updated:              #{updated}
      Errors:               #{errors.size}
    SUMMARY

    if errors.any?
      puts "Errors:"
      errors.each { |e| puts "  - #{e}" }
    end
  end
end
