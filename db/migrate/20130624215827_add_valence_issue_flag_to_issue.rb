class AddValenceIssueFlagToIssue < ActiveRecord::Migration
  def change
    add_column :issues, :valence_issue, :boolean
  end
end
