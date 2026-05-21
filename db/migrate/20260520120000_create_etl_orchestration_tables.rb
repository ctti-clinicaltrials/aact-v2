class CreateEtlOrchestrationTables < ActiveRecord::Migration[8.0]
  def change
    create_table :etl_runs do |t|
      t.string :status, null: false
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    create_table :etl_run_steps do |t|
      t.references :etl_run, null: false, foreign_key: true
      t.integer :position, null: false
      t.string :name, null: false
      t.string :status, null: false
      t.datetime :started_at
      t.datetime :finished_at
      t.bigint :core_job_id

      t.timestamps
    end

    add_index :etl_run_steps, [ :etl_run_id, :position ], unique: true
  end
end
