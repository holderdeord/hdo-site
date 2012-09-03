class AddLastUpdatedByToIssue < ActiveRecord::Migration
  def change
    add_column :issues, :last_updated_by_id, :integer
  end
end
