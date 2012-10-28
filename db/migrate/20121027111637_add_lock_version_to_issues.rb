class AddLockVersionToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :lock_version, :integer, default: 0, null: false
  end
end
