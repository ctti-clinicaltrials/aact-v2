module Api
  module V2
    class DataMappingController < ApplicationController
      def index
        mappings = Ctgov::AactMapping.joins(:api_metadata)
        render json: mappings.to_json(include: :api_metadata)
      end
    end
  end
end
