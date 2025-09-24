class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :password_digest, null: false
      t.boolean :email_verified, default: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.jsonb :preferences, default: {}
      
      t.timestamps
    end
    
    add_index :users, :reset_password_token, unique: true
  end
end
