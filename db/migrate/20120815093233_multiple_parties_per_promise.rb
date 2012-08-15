class MultiplePartiesPerPromise < ActiveRecord::Migration
  def up
    remove_column :promises, :party_id

    create_table :parties_promises, :id => false do |t|
      t.references :party, :promise
    end

    add_index :parties_promises, [:party_id, :promise_id]
  end

  def down
    drop_table :parties_promises
    add_column :promises, :party_id
  end
end
