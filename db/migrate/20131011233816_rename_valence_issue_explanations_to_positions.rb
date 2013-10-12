class RenameValenceIssueExplanationsToPositions < ActiveRecord::Migration
  def change
    rename_table :valence_issue_explanations, :positions
    rename_table :parties_valence_issue_explanations, :parties_positions
    rename_column :parties_positions, :valence_issue_explanation_id, :position_id

    # new
    rename_column :positions, :explanation, :description
    add_index :parties_positions, [:party_id, :position_id]
  end
end
