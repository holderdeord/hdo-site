class ChangePromiseDateToPeriod < ActiveRecord::Migration
  def up
    add_column :promises, :parliament_period_id, :integer

    # move current data..
    execute <<-SQL
      UPDATE promises
      SET parliament_period_id = parliament_periods.id
      FROM parliament_periods
      WHERE date IN (date('2009-06-01'), date('2009-10-07'), date('2009-10-01'))
      AND parliament_periods.external_id = '2009-2013'
    SQL

    remove_column :promises, :date
  end

  def down
    add_column :promises, :date, :date

    execute <<-SQL
      UPDATE promises
      SET date = parliament_periods.start_date
      FROM parliament_periods
      WHERE parliament_periods.id = parliament_period_id
    SQL

    remove_column :promises, :parliament_period_id
  end
end
