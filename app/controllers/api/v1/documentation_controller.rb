# FILE: app/controllers/api/v1/documentation_controller.rb
require "csv"
module Api
  module V1
    class DocumentationController < ApplicationController
      protect_from_forgery with: :null_session

      def index
        schema = Ctgov::V1Schema.all
        mappings = Ctgov::V1Mapping.all
        metadata = Ctgov::V1ApiMetadata.all

        documentation_service = V1DocumentationService.new(schema, mappings, metadata)
        docs = documentation_service.build_documentation

        respond_to do |format|
          format.json { render json: docs }
          format.csv { send_data documentation_service.generate_csv(docs), filename: "aact_documentation.csv" }
        end
      end

      def update
        record = Ctgov::V1Schema.find(params[:id])
        if record.update(doc_params)
          render json: record, status: :ok
        else
          render json: record.errors, status: :unprocessable_entity
        end
      end

      def doc_params
        params.require(:documentation).permit(:active, :description)
      end
    end
  end
end
