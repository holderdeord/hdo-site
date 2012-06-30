class Party < ActiveRecord::Base
  has_many :representatives, :order => :last_name
  has_many :promises

  validates_uniqueness_of :name
  validates_presence_of :name

  def percent_of_representatives
    total = Representative.count
    total = 1 if total.zero?

    representatives.size * 100 / total
  end
end
