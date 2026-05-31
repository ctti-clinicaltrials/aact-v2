# frozen_string_literal: true

class StatCardComponentPreview < ViewComponent::Preview
  def default
    render(StatCardComponent.new(label: "Total AACT Users", value: "10,196"))
  end

  def small_number
    render(StatCardComponent.new(label: "Joined Last 7 Days", value: "44"))
  end

  def with_unit
    render(StatCardComponent.new(label: "Avg Duration", value: "45 ms"))
  end
end
