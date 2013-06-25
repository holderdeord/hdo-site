class AddOverrideToPromiseConnections < ActiveRecord::Migration
  def change
    add_column :promise_connections, :override, :integer
  end
end
