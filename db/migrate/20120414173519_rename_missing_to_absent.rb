class RenameMissingToAbsent < ActiveRecord::Migration
  def change
    rename_column :votes, :missing_count, :absent_count
  end
end
