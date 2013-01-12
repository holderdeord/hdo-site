class Question < ActiveRecord::Base
  attr_accessible :title, :body, :sender, :representative_id

  validates :title,  presence: true, length: { maximum: 255 }
  validates :body,   presence: true
  validates :sender, email: true, allow_nil: true

  has_many :answers
  belongs_to :representative
end
