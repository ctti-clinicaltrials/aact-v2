# Seed users with varied data for local development.
# Covers: short/long names, different email formats, mixed DB access states,
# varied join dates, and migrated vs. non-migrated users.
#
# Admin login: admin_user@example.com / admin_user

puts "Seeding users..."

if Rails.env.production?
  puts "  Skipping user seeding in production environment."
  return
end

# --- Admin ---
User.find_or_create_by!(email_address: "admin_user@example.com") do |u|
  u.name = "Admin User"
  u.password = "admin_user"
  u.admin = true
  u.database_username = "admin_db"
  u.database_password = "fake_db_password"
  u.database_creation_status = "completed"
  u.migrated_at = 2.months.ago
  u.created_at = 1.year.ago
end

# --- Regular users with hand-picked variety ---
users_data = [
  # Short names
  { name: "Li Wei",         email: "li.wei@university.edu",              joined: 11.months.ago, migrated: 3.months.ago, db_user: "li_wei",      db_status: "completed" },
  { name: "Ana Ruiz",       email: "ana@clinic.org",                     joined: 10.months.ago, migrated: 2.months.ago, db_user: "ana_ruiz",    db_status: "completed" },
  { name: "Jo Kim",         email: "jo@research.io",                     joined: 9.months.ago,  migrated: nil,          db_user: nil,           db_status: "not_requested" },

  # Long names
  { name: "Dr. Alexander Mikhailovich Petrov-Sokolovsky", email: "alexander.petrov-sokolovsky@longname-university-hospital.edu", joined: 8.months.ago, migrated: 1.month.ago, db_user: "a_petrov_sokolovsky", db_status: "completed" },
  { name: "Maria Guadalupe Hernandez de la Cruz",        email: "mghernandez@centro-investigacion.mx",                          joined: 7.months.ago, migrated: nil,         db_user: nil,                   db_status: "not_requested" },

  # Various DB statuses
  { name: "Priya Sharma",       email: "priya.sharma@biotech.com",       joined: 6.months.ago,  migrated: 1.month.ago,  db_user: "priya_s",     db_status: "completed" },
  { name: "James Okonkwo",      email: "j.okonkwo@hospital.ng",          joined: 6.months.ago,  migrated: nil,          db_user: nil,           db_status: "pending" },
  { name: "Sarah Mitchell",     email: "smitchell@pharma-research.com",  joined: 5.months.ago,  migrated: nil,          db_user: nil,           db_status: "processing" },
  { name: "Yuki Tanaka",        email: "yuki.tanaka@med.ac.jp",          joined: 5.months.ago,  migrated: nil,          db_user: nil,           db_status: "failed" },

  # Typical researchers
  { name: "Emily Chen",         email: "echen@stanford.edu",             joined: 4.months.ago,  migrated: 2.weeks.ago,  db_user: "echen",       db_status: "completed" },
  { name: "Robert Williams",    email: "rwilliams@mayo.edu",             joined: 4.months.ago,  migrated: nil,          db_user: nil,           db_status: "not_requested" },
  { name: "Fatima Al-Hassan",   email: "falhassan@kau.edu.sa",           joined: 3.months.ago,  migrated: 1.week.ago,   db_user: "falhassan",   db_status: "completed" },
  { name: "David Park",         email: "dpark@nih.gov",                  joined: 3.months.ago,  migrated: nil,          db_user: "dpark",       db_status: "completed" },
  { name: "Olga Novikova",      email: "olga.novikova@msu.ru",           joined: 2.months.ago,  migrated: nil,          db_user: nil,           db_status: "not_requested" },
  { name: "Carlos Mendez",      email: "cmendez@unam.mx",               joined: 2.months.ago,  migrated: nil,          db_user: nil,           db_status: "pending" },

  # Common names for testing duplicates/searches
  { name: "John Doe",           email: "john.doe@example.com",           joined: 3.weeks.ago,   migrated: nil,          db_user: nil,           db_status: "not_requested" },
  { name: "John Doe",           email: "jdoe@test.org",                 joined: 2.weeks.ago,   migrated: nil,          db_user: nil,           db_status: "not_requested" },
  { name: "John Smith",         email: "john.smith@example.com",        joined: 1.week.ago,    migrated: nil,          db_user: nil,           db_status: "not_requested" },

  # Repeatable domains for search testing
  { name: "Alice Johnson",      email: "alice@example.com",             joined: 10.days.ago,   migrated: nil,          db_user: nil,           db_status: "not_requested" },
  { name: "Bob Brown",          email: "bob@example.com",               joined: 5.days.ago,    migrated: nil,          db_user: nil,           db_status: "not_requested" },
  { name: "Charlie Wilson",     email: "charlie@test.org",              joined: 3.days.ago,    migrated: nil,          db_user: nil,           db_status: "not_requested" },

  # Recent signups (no DB access, not migrated)
  { name: "Aisha Patel",        email: "aisha.p@gmail.com",              joined: 3.weeks.ago,   migrated: nil,          db_user: nil,           db_status: "not_requested" },
  { name: "Tom O'Brien",        email: "tobrien@partners.org",           joined: 2.weeks.ago,   migrated: nil,          db_user: nil,           db_status: "not_requested" },
  { name: "Mei-Ling Wu",        email: "mlwu@ntu.edu.tw",               joined: 10.days.ago,   migrated: nil,          db_user: nil,           db_status: "not_requested" },
  { name: "Hans Gruber",        email: "hgruber@charite.de",             joined: 1.week.ago,    migrated: nil,          db_user: nil,           db_status: "not_requested" },
  { name: "Nina Petrova",       email: "nina.p@karolinska.se",           joined: 5.days.ago,    migrated: nil,          db_user: nil,           db_status: "not_requested" },

  # Edge cases: long emails, special characters
  { name: "Jean-Pierre Dubois", email: "jean-pierre.dubois@institut-pasteur.fr",  joined: 45.days.ago,  migrated: nil,  db_user: nil,          db_status: "not_requested" },
  { name: "Saoirse O'Sullivan", email: "sosullivan@rcsi.ie",                      joined: 40.days.ago,  migrated: nil,  db_user: "sosullivan", db_status: "completed" },
  { name: "Björk Sigurdsson",   email: "bjork@landspitali.is",                    joined: 35.days.ago,  migrated: nil,  db_user: nil,          db_status: "not_requested" },

  # Very old account
  { name: "Patricia Thompson",  email: "pthompson@duke.edu",             joined: 2.years.ago,   migrated: 6.months.ago, db_user: "pthompson",   db_status: "completed" },

  # Brand new
  { name: "Raj Kapoor",         email: "raj.kapoor@aiims.edu.in",        joined: 1.day.ago,     migrated: nil,          db_user: nil,           db_status: "not_requested" }
]

users_data.each do |data|
  User.find_or_create_by!(email_address: data[:email]) do |u|
    u.name = data[:name]
    u.password = "password"
    u.database_username = data[:db_user]
    u.database_password = "fake_db_password" if data[:db_user].present?
    u.database_creation_status = data[:db_status]
    u.migrated_at = data[:migrated]
    u.created_at = data[:joined]
  end
end

puts "  #{User.count} users total (#{User.where(admin: true).count} admin)"
admin_user = User.find_by(admin: true)
puts "Admin login for development: #{admin_user&.email_address} / admin_user" if admin_user
