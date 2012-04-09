class AddBornToRepresentative < ActiveRecord::Migration
  def change
    add_column :representatives, :date_of_birth, :datetime
    add_column :representatives, :date_of_death, :datetime
  end
end
