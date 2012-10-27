class RenameDescriptionToTitleOnVoteConnection < ActiveRecord::Migration
  def up
    rename_column :vote_connections, :description, :title
  end

  def down
    rename_column :vote_connections, :title, :description
  end
end
