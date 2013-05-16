class MoveShelvedToInProgress < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE issues SET status = 'in_progress' WHERE status = 'shelved'
    SQL
  end

  def down
    # nothing to do
  end
end
