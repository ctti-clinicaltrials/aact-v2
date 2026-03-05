# Load seed files in alphabetical order.
# Each file should be idempotent (safe to run multiple times).
#
# Usage:
#   bin/rails db:seed        — run seeds standalone
#   bin/rails db:setup       — create + schema + seed (fresh start)
#   bin/rails db:reset       — drop + create + schema + seed (nuke & rebuild)

Dir[Rails.root.join("db/seeds/*.rb")].sort.each { |f| require f }
