class ValenceIssueExplanation < ActiveRecord::Base
  has_and_belongs_to_many :parties
  belongs_to :issue
  attr_accessible :explanation, :issue_id, :parties

  validates :parties,     presence: true
  validates :explanation, presence: true
  validate :issue_is_valence_issue


  private

  def issue_is_valence_issue
    unless issue && issue.valence_issue
      errors.add(:issue, :must_be_valence_issue)
    end
  end
end
