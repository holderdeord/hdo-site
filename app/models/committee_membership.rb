class CommitteeMembership < ActiveRecord::Base
  include Hdo::Model::OpenEndedDateRange

  attr_accessible :representative, :committee, :start_date, :end_date

  belongs_to :committee
  belongs_to :representative

  validate :no_overlap_for_same_committee

  private

  def no_overlap_for_same_committee
    existing = self.class.where(:representative_id => representative, :committee_id => committee).
                          where("end_date IS NULL OR end_date >= ?", start_date).to_a

    existing.delete self

    if existing.any?
      errors.add(:start_date, "#{start_date} overlaps existing committee membership: #{existing.inspect}")
    end
  end
end
