class ValenceIssueExplanation < ActiveRecord::Base
  has_and_belongs_to_many :parties
  belongs_to :issue
  attr_accessible :explanation, :issue_id, :parties
end
