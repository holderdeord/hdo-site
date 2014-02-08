class ParliamentSession < ActiveRecord::Base
  include Hdo::Model::FixedDateRange

  def votes
    Vote.where("time >= ? AND time <= ?", start_date, end_date)
  end
end
