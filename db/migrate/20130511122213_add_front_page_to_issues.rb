class AddFrontPageToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :frontpage, :boolean
  end
end
