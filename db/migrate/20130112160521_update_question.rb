class UpdateQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :representative_id, :integer, null: false
    add_column :questions, :status, :string, default: 'awaiting_control'

    add_index :questions, :representative_id
  end
end
