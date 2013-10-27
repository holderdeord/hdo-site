class CreateGovernments < ActiveRecord::Migration
  def up
    create_table :governments do |t|
      t.string :name

      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    create_table :governments_parties, :id => false do |t|
      t.references :party, :government
    end

    add_index :governments_parties, [:party_id, :government_id]

    # move data
    execute <<-SQL
      INSERT INTO governments (name, start_date, end_date, created_at, updated_at)
        SELECT ('Government ' || start_date), start_date, end_date, NOW(), NOW() 
        FROM governing_periods
        GROUP BY start_date, end_date;
        
      INSERT INTO governments_parties (government_id, party_id)
      SELECT governments.id, party_id 
      FROM governing_periods 
      JOIN governments ON governments.start_date = governing_periods.start_date 
                      AND ((governments.end_date = governing_periods.end_date) OR (governments.end_date IS NULL AND governing_periods.end_date IS NULL));
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
      INSERT INTO governing_periods (start_date, end_date, created_at, updated_at, party_id)
      SELECT start_date, end_date, NOW(), NOW(), governments_parties.party_id
      FROM governments
      JOIN governments_parties ON governments_parties.government_id = governments.id;
    SQL

    drop_table :governments
    drop_table :governments_parties
  end
end