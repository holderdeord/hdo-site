class SimplifyPromiseConnections < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE promise_connections SET status = 'kept' WHERE override = 100;
      UPDATE promise_connections SET status = 'partially_kept' WHERE override = 50;
      UPDATE promise_connections SET status = 'broken' WHERE override = 0;
    SQL

    remove_column :promise_connections, :override
  end

  def down
    add_column :promise_connections, :override, :integer

    say "can't restore for/against status data of promise_connections, using 'for'"

    execute <<-SQL
      UPDATE promise_connections SET override = 100 WHERE status = 'kept';
      UPDATE promise_connections SET override = 50 WHERE status = 'partially_kept';
      UPDATE promise_connections SET override = 0 WHERE status = 'broken';
      UPDATE promise_connections SET override = NULL WHERE status = 'related';
      UPDATE promise_connections SET status = 'for' WHERE override IS NOT NULL;
    SQL
  end
end
