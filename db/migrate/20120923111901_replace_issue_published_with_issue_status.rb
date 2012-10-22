class ReplaceIssuePublishedWithIssueStatus < ActiveRecord::Migration
  def up
    add_column :issues, :status, :string, default: 'in_progress'

    execute <<-SQL
      UPDATE issues SET status = 'published' WHERE published = true;
      UPDATE issues SET status = 'in_progress' WHERE published = false;
    SQL

    remove_column :issues, :published
  end

  def down
    add_column :issues, :published, :boolean, default: false

    execute <<-SQL
      UPDATE issues SET published = true WHERE status = 'published';
    SQL

    remove_column :issues, :status
  end
end
