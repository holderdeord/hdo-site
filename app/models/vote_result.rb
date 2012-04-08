class VoteResult < ActiveRecord::Base
  belongs_to :representative
  belongs_to :vote
  
  validates_uniqueness_of :result, :scope => [:representative_id, :vote_id]
  
  def human_result
    case result
    when 1
      Vote.human_attribute_name :for_count # TODO: :for etc.
    when 0
      Vote.human_attribute_name :missing_count
    when -1
      Vote.human_attribute_name :against_count
    else
      'unknown'
    end
  end
end
