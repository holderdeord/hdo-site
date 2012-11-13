class AddEditorIdToIssue < ActiveRecord::Migration
  def up
    add_column :issues, :editor_id, :integer
    execute "UPDATE issues SET editor_id = last_updated_by_id"
  end

  def down
    remove_column :issues, :editor_id
  end
end
