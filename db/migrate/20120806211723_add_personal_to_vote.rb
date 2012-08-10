class AddPersonalToVote < ActiveRecord::Migration
  def up
    add_column :votes, :personal, :boolean, :default => true

    # Update existing votes to set personal based on its current counts.
    #
    # Using models in migrations is generally discouraged, since the migration
    # may be run at any time during the project's lifetime and may have
    # changed significantly since the migration was written
    #
    # In this case, we're only relying only on the schema which should be ok.
    #
    Vote.where(:for_count => 0, :against_count => 0, :absent_count => 0).
         update_all(:personal => false)
  end

  def down
    remove_column :votes, :personal
  end

end
