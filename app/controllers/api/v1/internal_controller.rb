module Api
  module V1
    class InternalController < ApplicationController
      allow_unauthenticated_access
      skip_before_action :verify_authenticity_token
      wrap_parameters false

      LEGACY_USER_EMAIL = "legacy@aact.system"

      before_action :verify_internal_token
      before_action :set_current_user_from_email

      private

      def verify_internal_token
        token = request.headers["X-Internal-Token"]
        return if ActiveSupport::SecurityUtils.secure_compare(
          token.to_s, ENV.fetch("INTERNAL_API_TOKEN", "")
        )
        head :unauthorized
      end

      def set_current_user_from_email
        @current_user = User.find_by(email_address: params[:email]) ||
                        User.find_by!(email_address: LEGACY_USER_EMAIL)
      end
    end
  end
end
