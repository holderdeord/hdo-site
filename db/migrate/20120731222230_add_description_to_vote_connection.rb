class AddDescriptionToVoteConnection < ActiveRecord::Migration
  def change
    add_column :vote_connections, :description, :string
  end
end
