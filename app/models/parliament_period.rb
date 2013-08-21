class ParliamentPeriod < ActiveRecord::Base
  attr_accessible :start_date, :end_date

  has_many :promises

  def self.for_date(date)
    where('start_date <= date(?) AND end_date >= date(?)', date, date).first
  end

  def self.current
    for_date Date.current
  end

  def self.named(name)
    all.find { |e| e.name == name }
  end

  def name
    [start_date.year, end_date.year].join('-')
  end
end
