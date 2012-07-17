class AddDragonflyToFields < ActiveRecord::Migration
  def change
    add_column :fields, :image_uid, :string
    add_column :fields, :image_name, :string
  end
end
