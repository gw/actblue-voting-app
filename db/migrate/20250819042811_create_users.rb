class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :zip_code, null: false
      t.references :voted_for_candidate, null: true, foreign_key: { to_table: :candidates }

      t.timestamps
    end
    
    add_index :users, :email, unique: true
  end
end
