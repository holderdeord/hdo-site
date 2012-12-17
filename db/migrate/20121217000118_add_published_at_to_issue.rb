class AddPublishedAtToIssue < ActiveRecord::Migration
  def up
    add_column :issues, :published_at, :datetime, :default => nil

    execute <<-SQL
      UPDATE issues SET published_at = updated_at WHERE status = 'published';
    SQL
  end

  def down
    remove_column :issues, :published_at
  end
end
