class CreatePropositions < ActiveRecord::Migration
  def change
    create_table :propositions do |t|
      t.string  :external_id
      t.string  :representative_id
      t.integer :vote_id

      t.string :description
      t.string :body
      t.string :on_behalf_of

      t.timestamps
    end
  end
end
