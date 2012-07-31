class AddDragonflyFieldsToParties < ActiveRecord::Migration
  def change
    add_column :parties, :image_uid, :string
    add_column :parties, :image_name, :string
  end
end
