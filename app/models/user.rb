class User < ApplicationRecord
  has_secure_password

  enum :database_creation_status, {
    not_requested: "not_requested",
    pending: "pending",
    processing: "processing",
    completed: "completed",
    failed: "failed"
  }, prefix: :db_creation

  has_many :sessions, dependent: :destroy

  encrypts :database_password, deterministic: false

  attr_readonly :admin

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :name, presence: true
  validates :database_username, uniqueness: true, allow_blank: true

  # TODO: review database_user_created field use-case; consider removing it
  # Check if database user has been created
  def database_user_created?
    db_creation_completed?
  end

  # Check if user has database credentials
  def has_database_credentials?
    database_username.present? && database_password.present?
  end
end
