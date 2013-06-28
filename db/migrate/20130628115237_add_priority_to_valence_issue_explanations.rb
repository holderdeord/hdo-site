class AddPriorityToValenceIssueExplanations < ActiveRecord::Migration
  def change
    add_column :valence_issue_explanations, :priority, :int, default: 0
  end
end
