class CreateGoverningPeriods < ActiveRecord::Migration
  def change
    create_table :governing_periods do |t|
      t.date :start_date
      t.date :end_date
      t.references :party

      t.timestamps
    end
    add_index :governing_periods, :party_id
  end
end
