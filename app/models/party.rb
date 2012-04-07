class Party < ActiveRecord::Base
  has_many :representatives

  def percent_of_representatives
    representatives.count * 100 / Representative.count
  end
end
