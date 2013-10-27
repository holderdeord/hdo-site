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

  has_many :party_memberships,  dependent: :destroy
  has_many :representatives,    through:   :party_memberships
  has_many :promises,           as:        :promisor

  has_and_belongs_to_many :governments

  validates :name,        presence: true, uniqueness: true
  validates :external_id, presence: true, uniqueness: true

  friendly_id :external_id, use: :slugged

  attr_accessible :name

  def self.in_government
    gov = Government.current.first
    gov ? gov.parties : []
  end

  def in_government?(date = Date.today)
    gov = Government.for_date(date).first
    gov && gov.parties.include?(self)
  end

  def current_representatives
    representatives_at(Date.today).select(&:attending?)
  end

  def representatives_at(date)
    party_memberships.includes(:representative).for_date(date).map(&:representative).sort_by(&:last_name)
  end

  def image
    logger.warn "Party#image is deprecated, use Party#logo (from #{caller(0).to_s})"
    logo
  end
end
