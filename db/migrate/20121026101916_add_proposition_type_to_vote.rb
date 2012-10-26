class AddPropositionTypeToVote < ActiveRecord::Migration
  def change
    add_column :votes, :proposition_type, :string
  end
end
