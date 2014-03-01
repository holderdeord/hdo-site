# encoding: utf-8

class PromiseConnection < ActiveRecord::Base
  STATES          = %w[kept partially_kept broken related]
  UNRELATED_STATE = 'unrelated'

  attr_accessible :status, :promise_id, :promise, :issue

  belongs_to :promise
  belongs_to :issue

  validates :promise_id, presence: true, uniqueness: { scope: :issue_id }
  validates :issue_id, presence: true
  validates :status, presence: true, inclusion: { in: STATES }

  validate :only_related_promises_for_next_period

  def self.form_states
    STATES + [UNRELATED_STATE]
  end

  def kept?
    status.inquiry.kept?
  end

  def partially_kept?
    status.inquiry.partially_kept?
  end

  def related?
    status.inquiry.related?
  end

  def broken?
    status.inquiry.broken?
  end

  def future?
    promise.future?
  end

  def status_text
    case status
    when 'kept'
      'holdt'
    when 'partially_kept'
      'delvis holdt'
    when 'broken'
      'brutt'
    when 'related'
      'relatert'
    else
      raise "unknown status: #{status.inspect}"
    end
  end

  private

  def only_related_promises_for_next_period
    if !related? && promise && promise.future?
      errors.add(:promise, "must be from current parliament period or marked 'related' for issue connection")
    end
  end
end
