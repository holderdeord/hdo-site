class RemovePropositionSourceSlugs < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO proposition_endorsements (proposition_id, proposer_id, proposer_type)
      SELECT      propositions.id, parties.id, 'Party'
      FROM        propositions, parties
      WHERE       parties.slug = ANY(regexp_split_to_array(LOWER(propositions.source_slugs), E', *'));
    SQL

    execute <<-SQL
      INSERT INTO proposition_endorsements (proposition_id, proposer_id, proposer_type)
      SELECT      propositions.id, representatives.id, 'Representative'
      FROM        propositions, representatives
      WHERE       representatives.slug = ANY(regexp_split_to_array(lower(propositions.source_slugs), E', *'));
    SQL

    remove_column :propositions, :source_slugs
  end

  def down
    add_column :propositions, :source_slugs, :string

    execute <<-SQL
      UPDATE propositions
      SET    source_slugs = q.slugs
      FROM ( SELECT string_agg(parties.slug, ', ') AS slugs, proposition_endorsements.proposition_id as id
          FROM   proposition_endorsements, parties
          WHERE  proposition_endorsements.proposer_id = parties.id
            AND  proposition_endorsements.proposer_type = 'Party'
        GROUP BY proposition_endorsements.proposition_id
      ) AS q
      WHERE propositions.id = q.id
    SQL

    execute <<-SQL
      UPDATE propositions
      SET    source_slugs = concat_ws(', ', source_slugs, q.slugs)
      FROM (
          SELECT string_agg(representatives.slug, ', ') AS slugs, proposition_endorsements.proposition_id as id
            FROM proposition_endorsements, representatives
           WHERE proposition_endorsements.proposer_id = representatives.id
             AND proposition_endorsements.proposer_type = 'Representative'
        GROUP BY proposition_endorsements.proposition_id
      ) AS q
      WHERE propositions.id = q.id
    SQL
  end
end
