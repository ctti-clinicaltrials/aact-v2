# FILE: app/controllers/api/v1/documentation_controller.rb
require "csv"
module Api
  module V1
    class DocumentationController < ApplicationController
      # TODO: review CSRF protection before deploying
      protect_from_forgery with: :null_session

      def initialize
        super
        @documentation_service = V1DocumentationService.new(
          Ctgov::V1Schema.all,
          Ctgov::V1Mapping.all,
          Ctgov::V1ApiMetadata.all
        )
      end

      def index
        docs = @documentation_service.build_documentation

        respond_to do |format|
          format.json { render json: docs }
          format.csv { send_data documentation_service.generate_csv(docs), filename: "aact_documentation.csv" }
        end
      end

      def update
        result = @documentation_service.update_schema(params[:id], doc_params)

        if result.success?
          render json: result.record, status: :ok
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

      def doc_params
        params.require(:documentation).permit(:active, :description)
      end
    end
  end
end
