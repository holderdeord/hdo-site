class AddCarrierwaveForPartyAndRepresentative < ActiveRecord::Migration
  def up
    add_column :parties, :logo, :string
    add_column :representatives, :image, :string
  end

  def down
    remove_column :parties, :logo
    remove_column :representatives, :image, :string
  end
end
