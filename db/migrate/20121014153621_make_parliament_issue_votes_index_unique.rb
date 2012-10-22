class MakeParliamentIssueVotesIndexUnique < ActiveRecord::Migration

  def up
    remove_index 'parliament_issues_votes', name: index_name
    add_index "parliament_issues_votes", ["vote_id", "parliament_issue_id"], :name => index_name, unique: true
  end

  def down
    remove_index 'parliament_issues_votes', name: index_name
    add_index "parliament_issues_votes", ["vote_id", "parliament_issue_id"], :name => index_name
  end

  private

  def index_name
    "index_par_issues_votes_on_vote_id_and_par_issue_id"
  end
end
