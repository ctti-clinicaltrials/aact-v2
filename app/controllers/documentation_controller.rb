class DocumentationController < ApplicationController
  def index
    scope = DocumentationItem
      .search(search_param)
      .by_table(params[:table])
      .by_active(params[:active])
      .order(:table_name, :column_name)

    @pagy, @documentation = pagy(scope, limit: 20)
    @tables = DocumentationItem.table_names

    # Render only the results for Turbo Frame requests (smaller response)
    render :results if turbo_frame_request?
  end

  def show
    @doc_item = DocumentationItem.find_by(id: params[:id])

    if @doc_item.nil?
      redirect_to documentation_index_path, alert: "Documentation item not found"
    end
  end

  def download_csv
    scope = DocumentationItem
      .search(search_param)
      .by_table(params[:table])
      .by_active(params[:active])
      .order(:table_name, :column_name)

    all_docs = scope.limit(10000) # Safety limit

    csv_data = generate_csv(all_docs)

    send_data csv_data,
              filename: "aact_documentation_#{Time.current.strftime('%Y%m%d')}.csv",
              type: "text/csv"
  end

  private

  def search_param
    params[:search]&.strip&.slice(0, 100)
  end

  def generate_csv(docs)
    require "csv"

    # not including ctgov_path to user facing csv
    CSV.generate(headers: true) do |csv|
      csv << [
        "Active",
        "Table",
        "Column",
        "Data Type",
        "Nullable",
        "Description",
        "CTGov Section",
        "CTGov Module",
        "CTGov Data Point"
      ]

      docs.each do |doc|
        csv << [
          doc.active,
          doc.table_name,
          doc.column_name,
          doc.data_type,
          doc.nullable,
          doc.description,
          doc.ctgov_section,
          doc.ctgov_module,
          doc.ctgov_label
        ]
      end
    end
  end
end
