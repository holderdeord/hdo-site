class CreateDistricts < ActiveRecord::Migration
  def change
    create_table :districts do |t|
      t.string :external_id
      t.string :name

      t.timestamps
    end
  end
end
