class AddTitleToValenceIssueExplanation < ActiveRecord::Migration
  def change
    add_column :valence_issue_explanations, :title, :string
  end
end
