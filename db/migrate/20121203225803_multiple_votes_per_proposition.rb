class MultipleVotesPerProposition < ActiveRecord::Migration
  def up
    # create join table
    create_table :propositions_votes, id: false do |t|
      t.references :proposition, :vote
    end

    add_index :propositions_votes, [:proposition_id, :vote_id], uniq: true

    # move data
    execute <<-SQL
      INSERT INTO propositions_votes (proposition_id, vote_id)
      SELECT id, vote_id FROM propositions
    SQL

    remove_column :propositions, :vote_id
  end

  def down
    add_column :propositions, :vote_id, :integer

    # move data - we'll lose some for propositions
    # that has more than one vote
    execute <<-SQL
      UPDATE propositions
      SET vote_id = ( SELECT propositions_votes.vote_id
                       FROM propositions_votes
                       WHERE propositions_votes.proposition_id = propositions.id
                       LIMIT 1)
    SQL

    # remove join table
    drop_table :propositions_votes
  end
end
