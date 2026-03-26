class InstructionsController < ApplicationController
  allow_unauthenticated_access

  def postgres; end
  def flatfiles; end
  def covid19; end
end
