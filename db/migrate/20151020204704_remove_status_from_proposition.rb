class RemoveStatusFromProposition < ActiveRecord::Migration
  def up
    remove_column :propositions, :status
  end

  def down
    add_column :propositions, :status, :string, default: 'pending'
    add_index :propositions, :status
  end
end
