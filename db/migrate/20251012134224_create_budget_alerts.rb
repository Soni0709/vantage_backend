class CreateBudgetAlerts < ActiveRecord::Migration[8.0]
  def change
    create_table :budget_alerts, id: :uuid do |t|
      t.references :budget, type: :uuid, null: false, foreign_key: true, index: true
      t.string :alert_type, null: false # threshold_reached, budget_exceeded, near_limit
      t.string :severity, null: false # info, warning, error
      t.text :message, null: false
      t.decimal :budget_amount, precision: 15, scale: 2
      t.decimal :spent_amount, precision: 15, scale: 2
      t.decimal :percentage_used, precision: 5, scale: 2
      t.boolean :is_read, default: false
      t.boolean :is_acknowledged, default: false

      t.timestamps
    end

    add_index :budget_alerts, :is_read
    add_index :budget_alerts, :severity
  end
end
