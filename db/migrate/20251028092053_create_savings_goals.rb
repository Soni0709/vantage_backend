class CreateSavingsGoals < ActiveRecord::Migration[8.0]
  def change
    create_table :savings_goals, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :target_amount, precision: 15, scale: 2, null: false
      t.decimal :current_amount, precision: 15, scale: 2, default: 0
      t.date :deadline
      t.string :status, default: 'active' # active, completed, paused
      t.text :description

      t.timestamps
    end

    add_index :savings_goals, :status
    add_index :savings_goals, :deadline
  end
end
