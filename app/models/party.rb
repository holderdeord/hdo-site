class Party < ActiveRecord::Base
  include Hdo::Model::HasFallbackImage
  extend FriendlyId

  class PartyGroup < Struct.new(:name, :parties)
  end

  has_many :party_memberships, dependent: :destroy
  has_many :representatives, through: :party_memberships
  has_many :governing_periods, order: :start_date, dependent: :destroy

  has_and_belongs_to_many :promises, uniq: true

  validates_uniqueness_of :name, :external_id
  validates_presence_of :name, :external_id

  friendly_id :external_id, use: :slugged

  image_accessor :image
  attr_accessible :image, :name

  def self.in_government
    joins(:governing_periods).where("governing_periods.start_date < ? AND (end_date >= ? or end_date IS NULL)", Date.today, Date.today)
  end

  # TODO: find a better name for this
  def self.governing_groups
    government, opposition = order(:name).partition(&:in_government?)

    groups = []

    if government.any?
      groups << PartyGroup.new(I18n.t('app.parties.group.governing'), government)
      groups << PartyGroup.new(I18n.t('app.parties.group.opposition'), opposition)
    else
      # if no-one's in government, we only need a single group with no name.
      groups << PartyGroup.new('', opposition)
    end

    groups
  end

  def in_government?(date = Date.today)
    governing_periods.for_date(date).any?
  end

  def large_logo
    image_with_fallback.strip.url
  end

  def default_image
    default_logo = Rails.root.join("app/assets/images/party-logos/unknown.png")
    large_logo = Rails.root.join("app/assets/images/party-logos/#{URI.encode slug}.png")

    large_logo.exist? ? large_logo : default_logo
  end

  def current_representatives
    representatives_at Date.today
  end

  def representatives_at(date)
    party_memberships.includes(:representative).for_date(date).map { |e| e.representative }.sort_by { |e| e.last_name }
  end
end
