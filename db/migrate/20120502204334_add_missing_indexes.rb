class AddMissingIndexes < ActiveRecord::Migration
  def up
    add_index :issues, :committee_id
    add_index :promises, :party_id
    add_index :propositions, [:representative_id, :vote_id]
    add_index :representatives, :district_id
  end

  def down
    remove_index :issues, :committee_id
    remove_index :promises, :party_id
    remove_index :propositions, [:representative_id, :vote_id]
    remove_index :representatives, :district_id
  end
end
