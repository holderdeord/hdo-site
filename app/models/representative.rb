class Representative < ActiveRecord::Base
  belongs_to :party

  def display_name
    "#{last_name}, #{first_name}"
  end
end
