class AddPolymorphicPromisor < ActiveRecord::Migration
  def up
    add_column :promises, :promisor_id, :integer
    add_column :promises, :promisor_type, :string

    add_index :promises, [:promisor_id, :promisor_type]

    execute <<-SQL
      UPDATE promises SET promisor_id = parties_promises.party_id, promisor_type = 'Party'
      FROM parties_promises
      WHERE parties_promises.promise_id = promises.id
      AND (SELECT COUNT(*) FROM parties_promises WHERE parties_promises.promise_id = promises.id) = 1;

      UPDATE promises SET promisor_id = governments.id, promisor_type = 'Government'
      FROM governments, parties_promises, governments_parties
      WHERE promisor_id IS NULL -- avoid the ones already moved above
      AND parties_promises.promise_id = promises.id
      AND governments_parties.government_id = governments.id
      AND parties_promises.party_id = governments_parties.party_id
    SQL

    drop_table :parties_promises
  end

  def down
    create_table :parties_promises, :id => false do |t|
      t.references :party, :promise
    end

    add_index :parties_promises, [:party_id, :promise_id]

    # move data
    execute <<-SQL
      INSERT INTO parties_promises (party_id, promise_id)
      SELECT promisor_id, id
      FROM promises
      WHERE promisor_type = 'Party';

      INSERT INTO parties_promises (party_id, promise_id)
      SELECT governments_parties.party_id, id
      FROM promises, governments_parties
      WHERE promises.promisor_type = 'Government'
      AND governments_parties.government_id = promises.promisor_id;
    SQL

    remove_column :promises, :promisor_id, :promisor_type
  end
end
