class DistrictRepresentativeAssociation < ActiveRecord::Migration
  def up
    add_column :representatives, :district_id, :integer
  end

  def down
    remove_column :representatives, :district_id
  end
end
