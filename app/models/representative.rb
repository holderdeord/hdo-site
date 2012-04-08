class Representative < ActiveRecord::Base
  belongs_to :party
  belongs_to :district
  has_and_belongs_to_many :committees, :order => :name

  validates_uniqueness_of :first_name, :scope => :last_name # TODO: :scope => :period ?!

  def display_name
    "#{last_name}, #{first_name}"
  end
end
