class GoverningPeriod < ActiveRecord::Base
  belongs_to :party
  attr_accessible :end_date, :start_date, :party

  validates_presence_of :party, :start_date
  validate :start_date_must_be_before_end_date

  def start_date_must_be_before_end_date
    errors.add(:start_date, "must be before end date") if
      start_date && end_date && start_date >= end_date
  end

  def include?(date)
    date >= start_date && (end_date == nil || date < end_date)
  end

end
