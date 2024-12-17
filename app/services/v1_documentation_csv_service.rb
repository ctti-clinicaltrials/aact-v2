# app/services/documentation_csv_service.rb
class V1DocumentationCsvService
  HEADERS = {
    table_name: "Table",
    column_name: "Field",
    data_type: "Type",
    nullable: "Nullable",
    description: "Description",
    ctgov_data_point_label: "CTGov Data Point",
    ctgov_url: "CTGov Doc Link",
    ctgov_section: "CTGov API Section",
    ctgov_module: "CTGov API Module",
    ctgov_path:  "CTGov API Field Path"
  }.freeze

  def initialize(docs_data)
    @docs_data = docs_data
  end

  def generate
    CSV.generate(headers: true, col_sep: "|") do |csv|
      csv << HEADERS.values
      @docs_data.each do |doc|
        csv << build_row(doc)
      end
    end
  end

  private

  def build_row(doc)
    HEADERS.keys.map { |key| format_value(doc[key]) }
  end

  def format_value(value)
    case value
    when true then "Yes"
    when false then "No"
    when nil then nil
    when "" then nil
    else value.to_s
    end
  end
end
