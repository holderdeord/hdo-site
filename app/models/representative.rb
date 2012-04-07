class Representative < ActiveRecord::Base
  belongs_to :party
  has_and_belongs_to_many :committees

  validates_uniqueness_of :first_name, :scope => :last_name # TODO: :scope => :period ?!

  def display_name
    "#{last_name}, #{first_name}"
  end
end
