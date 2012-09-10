class ChangeTextToStringForVoteConnectionDescriptionAndComment < ActiveRecord::Migration
  def up
    change_column :vote_connections, :description, :text
    change_column :vote_connections, :comment, :text
  end

  def down
    change_column :vote_connections, :description, :string
    change_column :vote_connections, :comment, :string
  end
end
