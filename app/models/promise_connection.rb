class PromiseConnection < ActiveRecord::Base
  STATES          = %w[for against related]
  UNRELATED_STATE = 'unrelated'

  attr_accessible :status, :promise_id

  belongs_to :promise
  belongs_to :issue

  validates :promise, presence: true
  validates :issue, presence: true
  validates :status, presence: true, inclusion: { in: STATES }
end
