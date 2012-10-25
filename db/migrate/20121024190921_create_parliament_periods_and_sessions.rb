class CreateParliamentPeriodsAndSessions < ActiveRecord::Migration
  def change
    create_table :parliament_periods do |t|
      t.string :external_id
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end

    add_index :parliament_periods, :external_id, unique: true

    create_table :parliament_sessions do |t|
      t.string :external_id
      t.date :start_date, null: false
      t.date :end_date, null: false

      t.timestamps
    end

    add_index :parliament_sessions, :external_id, unique: true
  end
end
