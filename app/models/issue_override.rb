class IssueOverride < ActiveRecord::Base
  attr_accessible :score, :kind, :issue, :party

  belongs_to :party
  belongs_to :issue

  validates :kind, presence: true, inclusion: %w[promise position]
  validates :score, presence: true, inclusion: 0..100
end
