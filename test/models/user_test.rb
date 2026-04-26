require "test_helper"

class UserTest < ActiveSupport::TestCase
  def build_user(**overrides)
    User.new(
      email_address: "new@example.com",
      first_name: "Test",
      last_name: "User",
      password: "secretpw1",
      password_confirmation: "secretpw1",
      **overrides
    )
  end

  test "set_full_name derives name from first_name and last_name" do
    user = build_user
    user.valid?
    assert_equal "Test User", user.name
  end

  test "set_full_name strips surrounding whitespace from inputs" do
    user = build_user(first_name: "  Test  ", last_name: "  User  ")
    user.valid?
    assert_equal "Test User", user.name
  end

  test "first_name presence is required" do
    user = build_user(first_name: nil)
    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
  end

  test "last_name presence is required" do
    user = build_user(last_name: nil)
    assert_not user.valid?
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "first_name is invalid when blank or whitespace-only" do
    [ "", "   " ].each do |value|
      user = build_user(first_name: value)
      assert_not user.valid?, "expected first_name=#{value.inspect} to be invalid"
      assert_includes user.errors[:first_name], "can't be blank"
    end
  end

  test "last_name is invalid when blank or whitespace-only" do
    [ "", "   " ].each do |value|
      user = build_user(last_name: value)
      assert_not user.valid?, "expected last_name=#{value.inspect} to be invalid"
      assert_includes user.errors[:last_name], "can't be blank"
    end
  end

  test "first_name length is capped at 50" do
    user = build_user(first_name: "a" * 51)
    assert_not user.valid?
    assert_includes user.errors[:first_name], "is too long (maximum is 50 characters)"
  end

  test "valid user saves successfully" do
    assert build_user.save
  end
end
