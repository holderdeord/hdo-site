class CreateCommittees < ActiveRecord::Migration
  def change
    create_table :committees do |t|
      t.string :external_id
      t.string :name
      
      t.timestamps
    end
  end
end
