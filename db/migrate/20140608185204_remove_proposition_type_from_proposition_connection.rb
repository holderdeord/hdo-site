class RemovePropositionTypeFromPropositionConnection < ActiveRecord::Migration
  def up
    remove_column :proposition_connections, :proposition_type
  end

  def down
    add_column :proposition_connections, :string
  end
end
