class AddPromiseConnections < ActiveRecord::Migration
  def up
    create_table :promise_connections do |t|
      t.string  :status
      t.integer :promise_id
      t.integer :issue_id

      t.timestamps
    end

    add_index :promise_connections, [:promise_id, :issue_id]

    # in case old join records were left hanging, don't leave connections with invalid issues
    # see https://github.com/holderdeord/hdo-site/issues/351
    execute 'DELETE FROM issues_promises ip WHERE (SELECT count(*) FROM issues WHERE id = ip.issue_id) = 0'

    # move data
    execute <<-SQL
      INSERT INTO promise_connections (status, promise_id, issue_id, created_at, updated_at)
      SELECT 'related', promise_id, issue_id, now(), now() FROM issues_promises
    SQL

    drop_table :issues_promises
  end

  def down
    create_table :issues_promises, :id => false, :force => true do |t|
      t.integer :promise_id
      t.integer :issue_id
    end

    add_index :issues_promises, [:issue_id, :promise_id]

    execute <<-SQL
      INSERT INTO issues_promises (issue_id, promise_id)
      SELECT issue_id, promise_id from promise_connections
    SQL

    drop_table :promise_connections
  end
end
