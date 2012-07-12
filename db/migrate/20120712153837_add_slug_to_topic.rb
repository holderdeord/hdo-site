class AddSlugToTopic < ActiveRecord::Migration
  def up
    add_column :topics, :slug, :string
    add_index :topics, :slug, :unique => true
  end
  
  def down
    remove_index :topics, :slug
    remove_column :topics, :slug
  end
end
