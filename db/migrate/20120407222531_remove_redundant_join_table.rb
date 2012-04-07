class RemoveRedundantJoinTable < ActiveRecord::Migration
  def up
    drop_table :representatives_parties
  end

  def down
    create_table :representatives_parties, :id => false do |t|
      t.references :representative, :party
    end

    add_index :representatives_parties, [:representative_id, :party_id]
  end
end
