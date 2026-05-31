# frozen_string_literal: true

require "test_helper"

class StatCardComponentTest < ViewComponent::TestCase
  def test_renders_the_label_and_value
    render_inline(StatCardComponent.new(label: "Total AACT Users", value: "10,358"))

    assert_text "Total AACT Users"
    assert_text "10,358"
  end

  def test_value_is_styled_as_the_prominent_number
    render_inline(StatCardComponent.new(label: "Total AACT Users", value: "10,358"))

    # there is one visible div carrying both styles whose text includes 10,358
    assert_selector "dd.text-xl.font-bold", text: "10,358", count: 1
  end

  def test_accepts_non_string_values
    render_inline(StatCardComponent.new(label: "Total Snapshots", value: 10_358))

    assert_text "10358"
  end
end
