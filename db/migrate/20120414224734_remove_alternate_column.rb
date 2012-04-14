class RemoveAlternateColumn < ActiveRecord::Migration
  def change
    remove_column :representatives, :alternate
  end
end
