class RenameVoteDirectionToVoteConnection < ActiveRecord::Migration
  def up
    remove_index :vote_directions, [:vote_id, :topic_id]
    rename_table :vote_directions, :vote_connections
    add_index    :vote_connections, [:vote_id, :topic_id]
  end

  def down
    remove_index :vote_connections, [:vote_id, :topic_id]
    rename_table :vote_connections, :vote_directions
    add_index    :vote_directions, [:vote_id, :topic_id]
  end
end
