class AddParliamentPeriodIdToPositions < ActiveRecord::Migration
  def change
    add_column :positions, :parliament_period_id, :integer
  end
end
