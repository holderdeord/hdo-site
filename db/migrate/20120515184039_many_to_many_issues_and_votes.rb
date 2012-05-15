class ManyToManyIssuesAndVotes < ActiveRecord::Migration
  def up
    remove_column :votes, :issue_id

    create_table :issues_votes, :id => false do |t|
      t.references :issue, :vote
    end

    add_index :issues_votes, [:vote_id, :issue_id]
  end

  def down
    drop_table :issues_votes
    add_column :votes, :issue_id
  end
end
