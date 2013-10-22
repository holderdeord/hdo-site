class Government < ActiveRecord::Base
  include Hdo::Model::HasDateRange

  attr_accessible :name, :start_date, :end_date

  validates :name, presence: true, uniqueness: true
  validate :does_not_intersect

  private

  def does_not_intersect
    intersecting = self.class.all.find { |gov| intersects?(gov) }

    if intersecting
      errors.add :start_date, "cannot intersect existing government: #{intersecting.inspect}"
    end
  end
end
