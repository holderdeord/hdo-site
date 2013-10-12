class RemoveMatchesFromVoteConnection < ActiveRecord::Migration
  def up
    remove_column :vote_connections, :matches
  end

  def down
    add_column :vote_connections, :matches, :boolean
  end
end
