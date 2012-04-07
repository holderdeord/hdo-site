class RepresentativeCommitteeAssociation < ActiveRecord::Migration
  def up
    create_table :committees_representatives, :id => false do |t|
      t.references :committee, :representative
    end

    add_index :committees_representatives, [:committee_id, :representative_id], :name => "index_com_reps"
  end

  def down
    drop_table :committees_representatives
  end
end
