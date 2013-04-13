class Party < ActiveRecord::Base
  mount_uploader :logo, PartyUploader

  extend FriendlyId

  include Tire::Model::Search
  include Tire::Model::Callbacks

  tire.settings(TireSettings.default) {
    mapping {
      indexes :name, type: :string, boost: 20
      indexes :slug, type: :string, boost: 20
    }
  }

  has_many :governing_periods,  dependent: :destroy, order: :start_date
  has_many :party_memberships,  dependent: :destroy
  has_many :representatives,    through:   :party_memberships

  has_and_belongs_to_many :promises, uniq: true

  validates :name,        presence: true, uniqueness: true
  validates :external_id, presence: true, uniqueness: true

  friendly_id :external_id, use: :slugged

  attr_accessible :name

  def self.in_government
    today = Date.today

    joins(:governing_periods).
      where("start_date <= ? AND (end_date >= ? or end_date IS NULL)", today, today)
  end

  def in_government?(date = Date.today)
    governing_periods.for_date(date).any?
  end

  def current_representatives
    representatives_at(Date.today).reject(&:on_leave?)
  end

  def representatives_at(date)
    party_memberships.includes(:representative).for_date(date).map(&:representative).sort_by(&:last_name)
  end

  def image
    logger.warn "Party#image is deprecated, use Party#logo (from #{caller(0).to_s})"
    logo
  end
end
