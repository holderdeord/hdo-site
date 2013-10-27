class Government < ActiveRecord::Base
  include Hdo::Model::HasDateRange

  has_and_belongs_to_many :parties,  order: :name
  has_many                :promises, as:    :promisor

  attr_accessible :name, :start_date, :end_date, :party_ids

  validates :name, presence: true, uniqueness: true
  validate :does_not_intersect

  private

  def does_not_intersect
    intersecting = self.class.all.find { |gov| gov != self && intersects?(gov) }

    if intersecting
      errors.add :start_date, "#{start_date.inspect}..#{end_date.inspect} cannot intersect existing government: #{intersecting.inspect}"
    end
  end
end
