class PartyComment < ActiveRecord::Base
  belongs_to :party
  belongs_to :issue
  belongs_to :parliament_period

  attr_accessible :body, :party_id, :issue_id, :party, :issue, :parliament_period_id

  validates_uniqueness_of :party_id, scope: [:issue_id, :parliament_period_id]
  validates_presence_of :party, :issue, :parliament_period
end
