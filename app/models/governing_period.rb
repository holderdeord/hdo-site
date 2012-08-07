class GoverningPeriod < ActiveRecord::Base
  belongs_to :party
  attr_accessible :end_date, :start_date, :party, :party_id

  validates_presence_of :party, :start_date
  validate :start_date_must_be_before_end_date

  scope :for_date, lambda { |date| where("start_date <= ? and (end_date >= ? or end_date is null)", date, date) }

  def start_date_must_be_before_end_date
    errors.add(:start_date, "must be before end date") if
      start_date && end_date && start_date >= end_date
  end

  def include?(date)
    date >= start_date && (end_date == nil || date <= end_date)
  end

end
