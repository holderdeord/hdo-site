class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string  :external_id
      t.integer :parent_id
      t.string  :name
      t.boolean :main

      t.timestamps
    end
  end
end
