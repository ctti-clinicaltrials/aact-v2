class Ahoy::Visit < ApplicationRecord
  self.table_name = "ahoy_visits"

  has_many :events, class_name: "Ahoy::Event"
  belongs_to :user, optional: true

  # Ahoy's `ahoy.authenticate(user)` only attributes the current visit;
  # this also backfills prior anonymous visits sharing the visitor_token.
  def self.claim_anonymous_for(user, visitor_token:)
    where(visitor_token: visitor_token, user_id: nil).update_all(user_id: user.id)
  end
end
