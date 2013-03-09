class RemoveDragonflyFields < ActiveRecord::Migration
  def up
    remove_column :representatives, :image_uid, :image_name
    remove_column :parties, :image_uid, :image_name
  end

  def down
    add_column :representatives, :image_uid, :string
    add_column :representatives, :image_name, :string

    add_column :parties, :image_uid, :string
    add_column :parties, :image_name, :string
  end
end
