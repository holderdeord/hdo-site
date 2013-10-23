class CreateGovernments < ActiveRecord::Migration
  def up
    create_table :governments do |t|
      t.string :name

      t.date :start_date
      t.date :end_date

      t.timestamps
    end
    
    # move data
    execute <<-SQL
      INSERT INTO governments (name, start_date, end_date, created_at, updated_at) 
      SELECT ('Government ' || id), start_date, end_date, NOW(), NOW() from governing_periods;
    SQL
    
    drop_table :governing_periods
  end
  
  def down
    create_table :governing_periods do |t|
      t.date     :start_date
      t.date     :end_date
      t.integer  :party_id
      
      t.timestamps
    end

    add_index :governing_periods, [:party_id]
    
    # move data
    execute <<-SQL
      INSERT INTO governing_periods (start_date, end_date, created_at, updated_at)
      SELECT (start_date, end_date, NOW(), NOW()) from governments;
    SQL
    
    drop_table :governments
  end
end