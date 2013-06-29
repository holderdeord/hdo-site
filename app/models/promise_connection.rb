# encoding: utf-8

class PromiseConnection < ActiveRecord::Base
  STATES          = %w[for against related]
  UNRELATED_STATE = 'unrelated'

  attr_accessible :status, :promise_id, :promise, :issue, :override

  belongs_to :promise
  belongs_to :issue

  validates :promise_id, presence: true, uniqueness: { scope: :issue_id }
  validates :issue_id, presence: true
  validates :status, presence: true, inclusion: { in: STATES }
  validates :override, inclusion: 0..100, allow_nil: true

  validate :no_new_promises

  def for?
    status.inquiry.for?
  end

  def against?
    status.inquiry.against?
  end

  def related?
    status.inquiry.related?
  end

  def status_text
    case status
    when 'for'
      'støtter saken'
    when 'against'
      'støtter ikke saken'
    when 'related'
      'relatert til saken'
    else
      raise "unknown status: #{status.inspect}"
    end
  end

  def overridden?
    override != nil
  end

  private

  #
  # hack to avoid bad promise connections - obviously needs to change
  #

  def no_new_promises
    if promise && promise.parliament_period.external_id != '2009-2013'
      errors.add(:promise, "must be from 2009-2013 for issue connection")
    end
  end

end
