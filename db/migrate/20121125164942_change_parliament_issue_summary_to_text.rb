class ChangeParliamentIssueSummaryToText < ActiveRecord::Migration
  def up
    change_column :parliament_issues, :summary, :text
  end

  def down
    change_column :parliament_issues, :summary, :string
  end
end
