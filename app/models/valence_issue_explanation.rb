class ValenceIssueExplanation < ActiveRecord::Base
  has_and_belongs_to_many :parties
  belongs_to :issue
  attr_accessible :explanation, :issue_id, :parties, :title, :priority

  validates :parties,     presence: true
  validates :title,       presence: true

  def downcased_title
    @downcased_title ||= (
      t = title.to_s.strip
      "#{UnicodeUtils.downcase t[0]}#{t[1..-1]}"
    )
  end
end
