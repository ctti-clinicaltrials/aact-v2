class SyncUsersJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: 0 # temp until Sidekiq retry settings are finalized

  retry_on PG::ConnectionBad, wait: 30.seconds, attempts: 2
  discard_on ActiveRecord::RecordInvalid

  def perform
    url = ENV.fetch("AACT_ADMIN_DB_URL")
    conn = PG.connect(url)

    rows = conn.exec(<<~SQL)
      SELECT
        id, email, encrypted_password,
        remember_created_at,
        sign_in_count, current_sign_in_at, last_sign_in_at,
        current_sign_in_ip, last_sign_in_ip,
        first_name, last_name, username,
        confirmation_token, confirmed_at, confirmation_sent_at,
        db_activity, last_db_activity,
        admin, created_at,
        COALESCE(confirmed_at, created_at, confirmation_sent_at,
                 last_db_activity, last_sign_in_at, current_sign_in_at)
          AS account_created_at
      FROM ctgov.users
    SQL

    created = 0
    updated = 0
    errors = []

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
        id: row["id"],
        first_name: first.presence,
        last_name: last.presence,
        admin: row["admin"],
        created_at: row["created_at"],
        remember_created_at: row["remember_created_at"],
        confirmation_token: row["confirmation_token"],
        confirmed_at: row["confirmed_at"],
        confirmation_sent_at: row["confirmation_sent_at"],
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

      user.legacy_user_id = row["id"]
      user.first_name = first.presence
      user.last_name = last.presence
      user.name = name
      user.database_username = username
      user.migrated = true
      user.metadata = metadata
      user.password_digest = row["encrypted_password"]
      user.created_at = row["account_created_at"] if is_new && row["account_created_at"].present?

      user.save!

      is_new ? created += 1 : updated += 1
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
      errors << "row #{index + 1}: #{email} — #{e.message}"
    end

    if errors.any?
      errors.each { |e| Rails.logger.error "SyncUsersJob row error: #{e}" }

      Sentry.capture_message(
        "SyncUsersJob: #{errors.size} row sync errors",
        level: :warning,
        extra: { errors: errors, created: created, updated: updated }
      )
    end
  ensure
    conn&.close
  end
end
