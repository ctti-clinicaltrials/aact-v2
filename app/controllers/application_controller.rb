class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Method

  # DigitalOcean App Platform routes through Cloudflare, which replaces emails
  # in HTML with "[email protected]". This breaks Turbo Frame responses because
  # Cloudflare's decoder JS only runs on full page loads. This header disables it.
  before_action -> { response.headers["X-CF-Email-Obfuscation"] = "off" }

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
