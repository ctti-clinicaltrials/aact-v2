# frozen_string_literal: true

class StatCardComponent < ViewComponent::Base
  def initialize(label:, value:)
    @label = label
    @value = value
  end

  private

  attr_reader :label, :value
end
