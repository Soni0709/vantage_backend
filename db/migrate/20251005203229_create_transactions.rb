class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
    
    create_table :transactions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :category, null: false
      t.text :description
      t.date :transaction_date, null: false
      t.string :payment_method
      t.jsonb :metadata, default: {}

      t.timestamps
    end
    
    # Add indexes for better query performance
    add_index :transactions, :type
    add_index :transactions, :category
    add_index :transactions, :transaction_date
    add_index :transactions, [:user_id, :transaction_date]
  end
end