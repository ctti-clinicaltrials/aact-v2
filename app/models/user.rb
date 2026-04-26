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

  scope :search, ->(term) {
    return all if term.blank?
    where(
      "name ILIKE :q OR email_address ILIKE :q OR database_username ILIKE :q",
      q: "%#{term}%"
    )
  }

  encrypts :database_password, deterministic: false

  attr_readonly :admin

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :first_name, :last_name, with: ->(v) { v&.strip.presence }

  before_validation :set_full_name

  validates :email_address, presence: true, uniqueness: true
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
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

  private

  def set_full_name
    return unless first_name.present? || last_name.present?
    self.name = "#{first_name} #{last_name}".strip
  end
end
