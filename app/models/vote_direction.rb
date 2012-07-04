class VoteDirection < ActiveRecord::Base
  belongs_to :vote
  belongs_to :topic

  attr_accessible :vote, :vote_id, :topic, :matches
end
