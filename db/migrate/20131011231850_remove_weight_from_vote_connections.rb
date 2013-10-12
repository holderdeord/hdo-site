class RemoveWeightFromVoteConnections < ActiveRecord::Migration
  def up
    remove_column :vote_connections, :weight
  end

  def down
    add_column :vote_connections, :weight, :float, default: 1.0
  end
end
