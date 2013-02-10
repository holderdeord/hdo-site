class Answer < ActiveRecord::Base
  attr_accessible :body, :representative

  belongs_to :question
  belongs_to :representative

  validates :body,           presence: true
  validates :representative, presence: true
  validates :question,       presence: true

  def party
    representative.party_at created_at
  end
end
