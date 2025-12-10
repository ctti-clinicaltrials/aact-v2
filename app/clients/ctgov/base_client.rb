module CTGov
  # Base client for ClinicalTrials.gov API v2
  # Configures HTTP/2 support and CTGov-specific settings
  # All CTGov clients should inherit from this
  class BaseClient
    include HttpClient

    API_BASE_URL = "https://clinicaltrials.gov/api/v2"

    private

    def base_url
      API_BASE_URL
    end

    # CTGov API works better with HTTP/2 via Typhoeus adapter
    def configure_adapter(conn)
      conn.adapter :typhoeus, http_version: :httpv2_0
    end

    # CTGov API can be slow, use longer timeout
    def timeout
      30  # seconds
    end

    def open_timeout
      10  # seconds
    end
  end
end
