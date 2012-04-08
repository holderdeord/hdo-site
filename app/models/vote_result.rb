class VoteResult < ActiveRecord::Base
  belongs_to :representative
  belongs_to :vote

  validates_uniqueness_of :result, :scope => [:representative_id, :vote_id]

  def human
    case result
    when 1
      Vote.human_attribute_name :for_count # TODO: :for etc.
    when 0
      Vote.human_attribute_name :missing_count
    when -1
      Vote.human_attribute_name :against_count
    end
  end

  def state
    case result
    when 1
      :for
    when 0
      :missing
    when -1
      :against
    end
  end

  def for?
    result == 1
  end

  def against?
    result == -1
  end

  def missing?
    result == 0
  end

  def icon
    case result
    when 1
      'plus-sign'
    when -1
      'minus-sign'
    when 0
      'question-sign'
    end
  end

  def alert
    case result
    when 1
      'alert-success'
    when -1
      'alert-error'
    when 0
      'alert-info'
    end
  end

end
