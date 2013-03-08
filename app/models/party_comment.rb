class PartyComment < ActiveRecord::Base
  belongs_to :party
  belongs_to :issue
  attr_accessible :body, :title, :party_id, :issue_id
end
