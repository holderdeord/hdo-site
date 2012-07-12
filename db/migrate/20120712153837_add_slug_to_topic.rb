class AddSlugToTopic < ActiveRecord::Migration
  def up
    add_column :representatives, :slug, :string
    add_index :representatives, :slug, :unique => true
  end
  
  def down
    remove_index :representatives, :slug
    remove_column :representatives, :slug
  end
end
