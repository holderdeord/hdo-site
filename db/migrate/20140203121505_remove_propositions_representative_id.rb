class RemovePropositionsRepresentativeId < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO proposition_endorsements (proposition_id, proposer_id, proposer_type)
      SELECT id, representative_id::integer, 'Representative'
      FROM propositions
      WHERE propositions.representative_id IS NOT NULL
      AND NOT EXISTS(
        SELECT 1 FROM proposition_endorsements
        WHERE proposition_id = propositions.id
        AND proposer_id = propositions.representative_id::integer
        AND proposer_type = 'Representative'
      )
    SQL

    remove_column :propositions, :representative_id
  end

  def down
    add_column :propositions, :representative_id, :integer

    execute <<-SQL
      UPDATE propositions
      SET representative_id = endorsements.proposer_id
      FROM proposition_endorsements as endorsements
      WHERE endorsements.proposition_id = propositions.id
      AND endorsements.proposer_type = 'Representative'
    SQL
  end
end
