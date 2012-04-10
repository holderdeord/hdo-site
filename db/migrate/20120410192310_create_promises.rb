class CreatePromises < ActiveRecord::Migration
  def change
    create_table :promises do |t|
      t.integer :party_id
      t.string :body
      t.boolean :general
      t.string :source

      t.timestamps
    end
  end
end
