class RenameIssueToParliamentIssue < ActiveRecord::Migration
  def up
    # remove indeces
    remove_index :categories_issues, [:issue_id, :category_id]
    remove_index :issues, [:committee_id]
    remove_index :issues, [:slug]
    remove_index :issues_votes, [:vote_id, :issue_id]

    # rename the table
    rename_table :issues, :parliament_issues

    # rename column names on join tables
    rename_column :categories_issues, :issue_id, :parliament_issue_id
    rename_column :issues_votes, :issue_id, :parliament_issue_id

    # rename join tables
    rename_table :categories_issues, :categories_parliament_issues
    rename_table :issues_votes, :parliament_issues_votes

    # re-add indeces
    add_index :categories_parliament_issues, [:parliament_issue_id, :category_id], name: "index_cat_par_issue_on_par_issue_id_cat_id"
    add_index :parliament_issues, :committee_id
    add_index :parliament_issues, [:slug], unique: true
    add_index :parliament_issues_votes, [:vote_id, :parliament_issue_id], name: 'index_par_issues_votes_on_vote_id_and_par_issue_id'
  end

  def down
    # remove indeces
    remove_index :parliament_issues_votes, [:vote_id, :parliament_issue_id]
    remove_index :parliament_issues, :slug
    remove_index :parliament_issues, :committee_id
    remove_index :categories_parliament_issues, :name => "index_cat_par_issue_on_par_issue_id_cat_id"

    # rename join tables
    rename_table :parliament_issues_votes, :issues_votes
    rename_table :categories_parliament_issues, :categories_issues

    # rename column names on join tables
    rename_column :categories_issues, :parliament_issue_id, :issue_id
    rename_column :issues_votes, :parliament_issue_id, :issue_id

    # rename the table
    rename_table :parliament_issues, :issues

    # add indeces
    add_index :issues_votes, [:vote_id, :issue_id]
    add_index :issues, [:slug], unique: true
    add_index :issues, [:committee_id]
    add_index :categories_issues, [:issue_id, :category_id]
  end
end
