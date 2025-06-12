class CreateAactPublicQueryMetrics < ActiveRecord::Migration[7.2]
  def change
    create_table :aact_public_query_metrics do |t|
      t.date :log_date, null: false
      t.string :username, null: false
      t.integer :query_count, null: false, default: 0
      t.float :total_duration_ms, null: false, default: 0
      t.timestamps

      t.index [ :log_date, :username ], unique: true
    end
  end

  def down
    drop_table :database_query_metrics
  end
end
