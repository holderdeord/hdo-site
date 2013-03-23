class AddMoreAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :description, :text
    add_column :users, :active, :boolean
    add_column :users, :board, :boolean
  end
end
