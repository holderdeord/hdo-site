class AddSlugsForFriendlyId < ActiveRecord::Migration
  def up
    add_column :representatives, :slug, :string
    add_index :representatives, :slug, :unique => true

    add_column :committees, :slug, :string
    add_index :committees, :slug, :unique => true

    add_column :categories, :slug, :string
    add_index :categories, :slug, :unique => true

    add_column :districts, :slug, :string
    add_index :districts, :slug, :unique => true

    add_column :fields, :slug, :string
    add_index :fields, :slug, :unique => true

    add_column :issues, :slug, :string
    add_index :issues, :slug, :unique => true

    add_column :parties, :slug, :string
    add_index :parties, :slug, :unique => true

    add_column :votes, :slug, :string
    add_index :votes, :slug, :unique => true
  end

  def down
  	remove_index :representatives, :slug
  	remove_column :representatives, :slug

 	remove_index :committees, :slug
 	remove_column :committees, :slug

 	remove_index :categories, :slug
 	remove_column :categories, :slug

 	remove_index :districts, :slug
 	remove_column :districts, :slug

 	remove_index :fields, :slug
 	remove_column :fields, :slug

 	remove_index :issues, :slug
 	remove_column :issues, :slug

 	remove_index :parties, :slug
 	remove_column :parties, :slug

 	remove_index :votes, :slug
 	remove_column :votes, :slug
  end
end
