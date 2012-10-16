class ChangeIssueDescriptionToText < ActiveRecord::Migration
  def up
    change_column :issues, :description, :text
  end

  def down
    change_column :issues, :description, :string
  end
end
