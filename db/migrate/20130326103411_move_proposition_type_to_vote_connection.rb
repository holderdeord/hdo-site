class MovePropositionTypeToVoteConnection < ActiveRecord::Migration
  def up
    add_column :vote_connections, :proposition_type, :string

    execute <<-SQL
      UPDATE vote_connections
      SET proposition_type = (
        SELECT proposition_type
        FROM votes
        WHERE votes.id = vote_connections.vote_id
      )
    SQL

    remove_column :votes, :proposition_type
  end

  def down
    add_column :votes, :proposition_type, :string

    say "WARNING: destructive operation on rollback of proposition types, inevitable data loss"

    execute <<-SQL
      UPDATE votes
      SET proposition_type = (
        SELECT proposition_type
        FROM vote_connections
        WHERE votes.id = vote_connections.vote_id
        LIMIT 1
      )
    SQL

    remove_column :vote_connections, :proposition_type
  end
end
