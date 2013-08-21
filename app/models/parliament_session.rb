class ParliamentSession < ActiveRecord::Base
  attr_accessible :start_date, :end_date

  def self.for_date(date)
    where('start_date <= date(?) AND end_date >= date(?)', date, date).first
  end

  def self.current
    for_date Date.current
  end

  def name
    [start_date.year, end_date.year].join('-')
  end

  def votes
    Vote.where("time >= ? AND time <= ?", start_date, end_date)
  end
end
