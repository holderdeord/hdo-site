class ChangeVoteConnectionWeightToFloat < ActiveRecord::Migration
  def up
    change_column :vote_connections, :weight, :float
  end

  def down
    change_column :vote_connections, :weight, :integer
  end
end
