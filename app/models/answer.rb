class Answer < ActiveRecord::Base
  attr_accessible :body, :representative_id, :representative

  belongs_to :question
  belongs_to :representative

  validates :body,           presence: true
  validates :representative, presence: true
  validates :question,       presence: true

  validates_uniqueness_of :representative_id, scope: :question_id

  def party
    representative.party_at created_at
  end
end
