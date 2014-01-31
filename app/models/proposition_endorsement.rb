class PropositionEndorsement < ActiveRecord::Base
  attr_accessible :proposer, :proposition

  belongs_to :proposer, polymorphic: true
  belongs_to :proposition

  validates_uniqueness_of :proposition_id, scope: [:proposer_type, :proposer_id]
end
