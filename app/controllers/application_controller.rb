class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method
  # TODO: Does Pagy belongs to Application Controller?

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
