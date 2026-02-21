class AddMissingSolidQueueTables < ActiveRecord::Migration[8.1]
  def change
    # Add solid_queue_recurring_executions table if it doesn't exist
    unless table_exists?(:solid_queue_recurring_executions)
      create_table :solid_queue_recurring_executions do |t|
        t.references :job, null: false, foreign_key: { to_table: :solid_queue_jobs, on_delete: :cascade }
        t.string :task_key, null: false
        t.datetime :run_at, null: false
        t.timestamps

        t.index [:task_key, :run_at], unique: true
      end
    end

    # Add solid_queue_recurring_tasks table if it doesn't exist
    unless table_exists?(:solid_queue_recurring_tasks)
      create_table :solid_queue_recurring_tasks do |t|
        t.string :key, null: false
        t.string :schedule, null: false
        t.string :command, limit: 2048
        t.string :class_name
        t.text :arguments
        t.string :queue_name
        t.integer :priority, default: 0
        t.boolean :static, default: true, null: false
        t.text :description
        t.timestamps

        t.index :key, unique: true
        t.index :static
      end
    end

    # Add name column to solid_queue_processes if it doesn't exist
    if table_exists?(:solid_queue_processes) && !column_exists?(:solid_queue_processes, :name)
      add_column :solid_queue_processes, :name, :string, null: false

      # Remove old index if it exists
      remove_index :solid_queue_processes, name: "index_solid_queue_processes_on_supervisor_id", if_exists: true

      # Add new index with name column
      add_index :solid_queue_processes, [:name, :supervisor_id], unique: true
    end
  end
end
