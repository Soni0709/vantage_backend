class CreateRecurringTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :recurring_transactions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.text :description
      t.string :category, null: false
      t.string :frequency, null: false  # daily, weekly, monthly, yearly
      t.date :start_date, null: false
      t.date :end_date
      t.date :next_occurrence, null: false
      t.boolean :is_active, default: true
      t.jsonb :config, default: {}

      t.timestamps
    end
    
    # Add indexes for better query performance
    add_index :recurring_transactions, :type
    add_index :recurring_transactions, :category
    add_index :recurring_transactions, :frequency
    add_index :recurring_transactions, :is_active
    add_index :recurring_transactions, :next_occurrence
    add_index :recurring_transactions, [:user_id, :is_active]
  end
end