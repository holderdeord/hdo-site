class PartyMembership < ActiveRecord::Base
  attr_accessible :party, :representative, :start_date, :end_date

  belongs_to :party
  belongs_to :representative

  validate :start_date_must_be_before_end_date
  validate :no_concurrent_memberships

  scope :for_date, lambda { |date| where('start_date <= date(?) AND (end_date >= date(?) OR end_date IS NULL)', date, date) }
  scope :current, lambda { for_date(Time.now) }

  def current?
    include? Time.now
  end

  def include?(date)
    date >= start_date && (end_date == nil || date <= end_date)
  end

  def intersects?(other)
    if start_date == other.start_date
      true
    elsif start_date > other.start_date
      start_date <= (other.end_date || Date.today)
    else
      other.start_date <= (end_date || Date.today)
    end
  end

  def open_ended?
    end_date.nil?
  end

  private

  def start_date_must_be_before_end_date
    if start_date && end_date && start_date >= end_date
      errors.add(:start_date, "must be before end date")
    end
  end

  def no_concurrent_memberships
    # yes, this is correct.
    existing = self.class.where("representative_id = ? AND (end_date IS NULL OR end_date >= ?)", representative_id, start_date).to_a
    existing -= [self] # allow updates to existing membership

    if existing.any?
      errors.add :start_date, "#{start_date} overlaps existing membership: #{existing.inspect}"
    end
  end
end
