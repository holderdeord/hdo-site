class AddPrimaryKeyToPropositionEndorsements < ActiveRecord::Migration
  def change
    add_column :proposition_endorsements, :id, :primary_key
  end
end
