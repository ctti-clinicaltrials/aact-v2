# FILE: app/controllers/api/v1/documentation_controller.rb
require "csv"
module Api
  module V1
    class DocumentationController < ApplicationController
      # Skip authentication for API endpoints (server-to-server)
      allow_unauthenticated_access
      
      # TODO: review before deploying
      # Completely skips CSRF verification for all actions in this controller
      skip_before_action :verify_authenticity_token

      before_action :setup_documentation_service


      def index
        docs = @documentation_service.build_documentation

        # TODO: handle empty docs object
        respond_to do |format|
          format.json { render json: docs }
          format.csv do
            csv_service = V1DocumentationCsvService.new(docs)
            send_data csv_service.generate,
                      filename: "aact_documentation.csv",
                      type: "text/csv"
          end
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

      def setup_documentation_service
        @documentation_service = V1DocumentationService.new
      end
    end
  end
end
