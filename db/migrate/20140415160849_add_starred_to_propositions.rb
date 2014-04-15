class AddStarredToPropositions < ActiveRecord::Migration
  def change
    add_column :propositions, :starred, :boolean, default: false
  end
end
