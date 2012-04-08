class Party < ActiveRecord::Base
  has_many :representatives, :order => :last_name

  validates_uniqueness_of :name

  def percent_of_representatives
    representatives.count * 100 / Representative.count
  end
end
