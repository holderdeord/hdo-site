class RenameVoteConnectionsToPropositionConnections < ActiveRecord::Migration
  def up
    remove_index :vote_connections, name: :index_vote_connections_on_vote_id_and_issue_id
    rename_table :vote_connections,        :proposition_connections

    add_column   :proposition_connections, :proposition_id, :integer
    add_index    :proposition_connections, :proposition_id
    add_index    :proposition_connections, [:vote_id, :issue_id]
  end

  def down
    remove_index :proposition_connections, name: :index_proposition_connections_on_proposition_id
    remove_index :proposition_connections, name: :index_proposition_connections_on_vote_id_and_issue_id

    remove_column :proposition_connections, :proposition_id

    rename_table :proposition_connections, :vote_connections
    add_index    :vote_connections, [:vote_id, :issue_id]
  end
end
