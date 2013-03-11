class PartyComment < ActiveRecord::Base
  belongs_to :party
  belongs_to :issue
  attr_accessible :body, :party_id, :issue_id, :party, :issue

  validates_uniqueness_of :party_id, scope: :issue_id


end
