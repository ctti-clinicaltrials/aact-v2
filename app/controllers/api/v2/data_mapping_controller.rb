# NOT USED FOR BUILDING DOCS FOR AACT ADMIN
# v2 namespace is for future API endpoints exposed to the public
module Api
  module V2
    class DataMappingController < ApplicationController
      # Skip authentication for API endpoints (server-to-server)
      allow_unauthenticated_access
      
      def index
        mappings = Ctgov::AactMapping.joins(:api_metadata)
        render json: mappings.to_json(include: :api_metadata)
      end
    end
  end
end
