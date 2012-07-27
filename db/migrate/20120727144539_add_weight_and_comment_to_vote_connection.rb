class AddWeightAndCommentToVoteConnection < ActiveRecord::Migration
  def change
    add_column :vote_connections, :weight, :integer, :default => 1
    add_column :vote_connections, :comment, :string
  end
end
