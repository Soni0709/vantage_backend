class CreateBudgets < ActiveRecord::Migration[8.0]
  def change
    create_table :budgets, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :category, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.string :period, null: false # weekly, monthly, quarterly, yearly, custom
      t.date :start_date, null: false
      t.date :end_date
      t.integer :alert_threshold, default: 80
      t.boolean :alert_enabled, default: true
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :budgets, [:user_id, :category, :period]
    add_index :budgets, :period
    add_index :budgets, :start_date
  end
end
