class EmailEvent < ActiveRecord::Base
  attr_accessible :email_address, :email_type

  validates :email_address, email: true
  validates :email_type, presence: true
end
