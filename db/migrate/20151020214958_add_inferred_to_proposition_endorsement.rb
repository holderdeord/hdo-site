class AddInferredToPropositionEndorsement < ActiveRecord::Migration
  def change
    add_column :proposition_endorsements, :inferred, :boolean, default: false
  end
end
