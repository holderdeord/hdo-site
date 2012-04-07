class PartyRepresentativeAssociation < ActiveRecord::Migration
  def up
    add_column :representatives, :party_id, :integer

    create_table :representatives_parties, :id => false do |t|
      t.references :representative, :party
    end

    add_index :representatives_parties, [:representative_id, :party_id]
  end

  def down
    drop_table :representatives_parties
  end
end
