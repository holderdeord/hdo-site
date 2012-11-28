class Question < ActiveRecord::Base
  # attr_accessible :title, :body

  validates :title,  presence: true, length: { maximum: 255 }
  validates :body,   presence: true
  validates :sender, email: true, allow_nil: true
end
