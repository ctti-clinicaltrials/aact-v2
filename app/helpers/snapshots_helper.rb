module SnapshotsHelper
  SNAPSHOT_CONFIG = {
    "pgdump" => {
      title: "PostgreSQL Database Dump",
      description: "A complete PostgreSQL dump you can restore locally with pg_restore. Ideal for complex queries and integrations.",
      instructions_path: :postgres_instructions_path
    },
    "flatfiles" => {
      title: "Flat Text Files",
      description: "Pipe-delimited text files — one file per table. Import into R, SAS, Python, or any analysis tool.",
      instructions_path: :flatfiles_instructions_path
    },
    "covid" => {
      title: "COVID-19 Spreadsheets",
      description: "COVID-19 clinical trial data in spreadsheet format. Note: no longer actively generated.",
      instructions_path: :covid19_instructions_path
    }
  }.freeze

  def snapshot_title(type)
    SNAPSHOT_CONFIG.dig(type, :title) || "Unknown Type"
  end

  def snapshot_description(type)
    SNAPSHOT_CONFIG.dig(type, :description) || ""
  end

  def snapshot_instructions_url(type)
    path_method = SNAPSHOT_CONFIG.dig(type, :instructions_path)
    send(path_method) if path_method
  end
end
