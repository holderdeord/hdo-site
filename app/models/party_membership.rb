class PartyMembership < ActiveRecord::Base
  include Hdo::Model::HasDateRange

  attr_accessible :party, :representative, :start_date, :end_date

  belongs_to :party
  belongs_to :representative

  validate :no_concurrent_memberships

  private

  def no_concurrent_memberships
    existing = self.class.where(:representative_id => representative).
                          where("(end_date IS NULL and (start_date <= ?)) or (end_date >= ? and end_date <= ?)", end_date, start_date, end_date).to_a



    existing.delete self

    if existing.any?
      errors.add :start_date, "#{start_date} overlaps existing party membership: #{existing.inspect}"
    end
  end
end
