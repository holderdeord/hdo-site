class AddDefaultValueForValenceIssue < ActiveRecord::Migration
  def up
    change_column :issues, :valence_issue, :boolean, default: false
    execute 'UPDATE issues SET valence_issue = false WHERE valence_issue IS NULL'
  end

  def down
    change_column :issues, :valence_issue, :boolean, default: nil
  end
end
