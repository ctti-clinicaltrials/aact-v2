module Ctgov
  # Client for fetching CTGov API metadata
  # Endpoint: https://clinicaltrials.gov/api/v2/studies/metadata
  # Returns hierarchical JSON describing all available API fields
  class MetadataClient < BaseClient
    def fetch
      connection.get("studies/metadata").body
    rescue Faraday::Error => e
      Rails.logger.error("CTGov metadata fetch failed: #{e.message}")
      raise
    end
  end
end
