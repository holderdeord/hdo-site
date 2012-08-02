class FixesForPostgres < ActiveRecord::Migration
  def up
    change_column :issues, :description, :text
    change_column :promises, :body, :text
  end

  def down
    change_column :issues, :description, :string
    change_column :promises, :body, :string
  end
end
