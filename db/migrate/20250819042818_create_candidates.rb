class CreateCandidates < ActiveRecord::Migration[7.0]
  def change
    create_table :candidates do |t|
      t.string :name, null: false

      t.timestamps
    end
    
    add_index :candidates, :name, unique: true
  end
end
