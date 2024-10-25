module Api
  module V1
    class DocumentationController < ApplicationController
      def index
        # TODO: review returning active only records
        schema = Ctgov::V1Schema.all
        mappings = Ctgov::V1Mapping.all
        metadata = Ctgov::V1ApiMetadata.all

        documentation_service = V1DocumentationService.new(schema, mappings, metadata)
        docs = documentation_service.build_documentation

        render json: docs
      end
    end
  end
end
