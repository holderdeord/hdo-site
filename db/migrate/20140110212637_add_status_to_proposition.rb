class AddStatusToProposition < ActiveRecord::Migration
  def change
    add_column :propositions, :status, :string, default: 'pending'
    add_index :propositions, :status
  end
end
