class VoteResult < ActiveRecord::Base
  attr_accessible :representative, :result

  belongs_to :representative
  belongs_to :vote

  validates_uniqueness_of :representative_id, scope: [:vote_id]

  def human
    case result
    when 1
      Vote.human_attribute_name :for_count # TODO: :for etc.
    when 0
      Vote.human_attribute_name :absent_count
    when -1
      Vote.human_attribute_name :against_count
    end
  end

  def state
    case result
    when 1
      :for
    when 0
      :absent
    when -1
      :against
    end
  end

  def for?
    result == 1
  end

  def against?
    result == -1
  end

  def absent?
    result == 0
  end

  def present?
    result != 0
  end

  def rebel?
    if absent?
      false
    else
      resp = connection.execute(REBEL_SQL % { vote_result_id: id })
      Integer(resp.max_by { |e| Integer(e['cnt']) }['result']) != result
    end
  end

  def rebel_old?
    party  = representative.party_at(vote.time)
    stats  = vote.stats

    stats.party_for?(party) && against? || stats.party_against?(party) && for?
  end

  def icon
    case result
    when 1
      'plus-sign'
    when -1
      'minus-sign'
    when 0
      'question-sign'
    end
  end

  def alert
    case result
    when 1
      'alert-success'
    when -1
      'alert-error'
    when 0
      'alert-info'
    end
  end

  REBEL_SQL = <<-SQL
select
  vote_results.result as result,
  count(*) as cnt
from
  votes,
  vote_results,
  party_memberships,
  parties,
  (SELECT
    parties.id as party_id,
    vote_results.id as vote_result_id,
    votes.id as vote_id
  FROM
    votes,
    vote_results,
    party_memberships,
    parties
  WHERE
        vote_results.id = %{vote_result_id}
    AND vote_results.vote_id = votes.id
    AND party_memberships.representative_id = vote_results.representative_id
    AND party_memberships.start_date <= DATE(votes.time)
    AND (party_memberships.end_date IS NULL OR party_memberships.end_date >= date(votes.time))
    AND parties.id = party_memberships.party_id
  ) AS origin
WHERE
      parties.id = origin.party_id
  AND votes.id = origin.vote_id
  AND vote_results.vote_id = votes.id
  AND party_memberships.representative_id = vote_results.representative_id
  AND party_memberships.start_date <= DATE(votes.time)
  AND (party_memberships.end_date IS NULL OR party_memberships.end_date >= date(votes.time))
  AND parties.id = party_memberships.party_id
GROUP BY
  vote_results.result
SQL


end
