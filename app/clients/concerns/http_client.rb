# Generic HTTP client concern for API integrations
# Include in any client class to get Faraday-based HTTP functionality
# Override methods to customize behavior per API
module HttpClient
  extend ActiveSupport::Concern

  included do
    attr_reader :connection
  end

  def initialize
    @connection = build_connection
  end

  private

  def build_connection
    Faraday.new(url: base_url) do |conn|
      configure_middleware(conn)
      configure_adapter(conn)
      configure_timeouts(conn)
    end
  end

  # Override in client if different middleware needed
  def configure_middleware(conn)
    conn.request :json
    conn.request :retry, retry_options
    conn.response :logger, Rails.logger, { headers: false, bodies: false, errors: true }
    conn.response :raise_error  # Raise on 4xx/5xx
    conn.response :json  # Auto-parse JSON responses
  end

  # Override in client for different adapter (e.g., Typhoeus for HTTP/2)
  def configure_adapter(conn)
    conn.adapter :net_http  # Default adapter
  end

  # Override in client if different timeouts needed
  def configure_timeouts(conn)
    conn.options.timeout = timeout
    conn.options.open_timeout = open_timeout
  end

  def retry_options
    {
      max: 3,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2,
      methods: [ :get ],
      exceptions: [
        Faraday::TimeoutError,
        Faraday::ConnectionFailed,
        Faraday::ServerError
      ]
    }
  end

  def timeout
    10  # seconds
  end

  def open_timeout
    5  # seconds
  end

  # Must be implemented by including class
  def base_url
    raise NotImplementedError, "Define base_url in #{self.class.name}"
  end
end
