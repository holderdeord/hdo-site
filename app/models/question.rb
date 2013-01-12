class Question < ActiveRecord::Base
  validates :title,  presence: true, length: { maximum: 255 }
  validates :body,   presence: true
  validates :sender, email: true, allow_nil: true

  has_many :answers
end
