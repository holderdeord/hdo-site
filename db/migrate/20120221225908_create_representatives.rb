class CreateRepresentatives < ActiveRecord::Migration
  def change
    create_table :representatives do |t|
      t.string :external_id
      t.string :first_name
      t.string :last_name

      t.timestamps
    end

    add_index :representatives, :last_name
  end
end
