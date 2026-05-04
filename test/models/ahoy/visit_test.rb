require "test_helper"

class Ahoy::VisitTest < ActiveSupport::TestCase
  def create_visit(**attrs)
    Ahoy::Visit.create!(visit_token: SecureRandom.uuid, **attrs)
  end

  test "claim_anonymous_for assigns a matching anonymous visit to the user" do
    user = users(:one)
    token = "visitor-abc"

    visit = create_visit(visitor_token: token)

    Ahoy::Visit.claim_anonymous_for(user, visitor_token: token)

    assert_equal user.id, visit.reload.user_id
  end

  test "claim_anonymous_for backfills multiple visits sharing the visitor_token" do
    user = users(:one)
    token = "visitor-abc"

    earlier = create_visit(visitor_token: token)
    current = create_visit(visitor_token: token)

    Ahoy::Visit.claim_anonymous_for(user, visitor_token: token)

    assert_equal user.id, earlier.reload.user_id
    assert_equal user.id, current.reload.user_id
  end

  test "claim_anonymous_for does not reassign visits owned by another user" do
    user       = users(:one)
    other_user = users(:two)
    token      = "visitor-abc"

    already_claimed = create_visit(visitor_token: token, user: other_user)

    Ahoy::Visit.claim_anonymous_for(user, visitor_token: token)

    assert_equal other_user.id, already_claimed.reload.user_id
  end

  test "claim_anonymous_for ignores visits with a different visitor_token" do
    user = users(:one)

    other_visit = create_visit(visitor_token: "different-token")

    Ahoy::Visit.claim_anonymous_for(user, visitor_token: "visitor-abc")

    assert_nil other_visit.reload.user_id
  end
end
