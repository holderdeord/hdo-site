class CreateGovernments < ActiveRecord::Migration
  def change
    create_table :governments do |t|
      t.string :name

      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end