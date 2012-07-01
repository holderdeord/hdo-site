class CreateVoteDirections < ActiveRecord::Migration
  def change
    create_table :vote_directions do |t|
      t.boolean  :matches
      t.integer  :vote_id
      t.integer  :topic_id

      t.timestamps
    end
    
    add_index :vote_directions, [:vote_id, :topic_id]
  end
end
