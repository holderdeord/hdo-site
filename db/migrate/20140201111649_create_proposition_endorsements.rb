class CreatePropositionEndorsements < ActiveRecord::Migration
  def change
    create_table :proposition_endorsements, id: false do |t|
      t.references :proposition
      t.references :proposer, polymorphic: true
    end
  end
end
