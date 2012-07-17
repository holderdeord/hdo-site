class AddDragonflyFieldsToRepresentative < ActiveRecord::Migration
  def change
    add_column :representatives, :image_uid, :string
    add_column :representatives, :image_name, :string
  end
end
