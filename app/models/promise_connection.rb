# encoding: utf-8

class PromiseConnection < ActiveRecord::Base
  STATES          = %w[for against related]
  UNRELATED_STATE = 'unrelated'

  attr_accessible :status, :promise_id, :promise, :issue

  belongs_to :promise
  belongs_to :issue

  validates :promise_id, presence: true, uniqueness: { scope: :issue_id }
  validates :issue_id, presence: true
  validates :status, presence: true, inclusion: { in: STATES }

  def for?
    status.inquiry.for?
  end

  def against?
    status.inquiry.against?
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

end
