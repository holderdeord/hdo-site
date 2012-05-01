class CreateVoteResults < ActiveRecord::Migration
  def change
    create_table :vote_results do |t|
      t.integer :representative_id
      t.integer :vote_id
      t.integer :result

      t.timestamps
    end

    add_index :vote_results, [:representative_id, :vote_id]
  end
end
