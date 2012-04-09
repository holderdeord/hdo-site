class AddBornToRepresentative < ActiveRecord::Migration
  def change
    add_column :representatives, :born, :datetime
  end
end
