class EmailEvent < ActiveRecord::Base
  belongs_to :email_eventable, polymorphic: true
  attr_accessible :email_address, :email_type

  validates :email_address, email: true
  validates :email_type, presence: true
end
