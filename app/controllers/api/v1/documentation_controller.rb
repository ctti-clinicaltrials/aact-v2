# FILE: app/controllers/api/v1/documentation_controller.rb
require "csv"
module Api
  module V1
    class DocumentationController < ApplicationController
      def index
        schema = Ctgov::V1Schema.all
        mappings = Ctgov::V1Mapping.all
        metadata = Ctgov::V1ApiMetadata.all

        documentation_service = V1DocumentationService.new(schema, mappings, metadata)
        docs = documentation_service.build_documentation

        respond_to do |format|
          format.json { render json: docs }
        end
      end

      end
    end
  end
end
