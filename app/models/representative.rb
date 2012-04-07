class Representative < ActiveRecord::Base
  belongs_to :party
  has_and_belongs_to_many :committees

  def display_name
    "#{last_name}, #{first_name}"
  end
end
