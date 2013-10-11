class RemoveValenceIssueFlagFromIssue < ActiveRecord::Migration
  def up
    remove_column :issues, :valence_issue
  end

  def down
    add_column :issues, :valence_issue, :boolean, default: false
  end
end
