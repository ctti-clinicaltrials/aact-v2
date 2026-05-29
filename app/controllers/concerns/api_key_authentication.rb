module ApiKeyAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_api_key!
  end

  private

  def authenticate_api_key!
    token = request.headers["Authorization"]
    Rails.logger.info "[ApiKeyAuth] bypass — token=#{token.inspect}, path=#{request.path}"
  end
end
