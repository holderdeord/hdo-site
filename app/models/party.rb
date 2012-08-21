class Party < ActiveRecord::Base
  class PartyGroup < Struct.new(:name, :parties)
  end

  extend FriendlyId

  include Hdo::ModelHelpers::HasFallbackImage
  include Hdo::ModelHelpers::HasRepresentatives

  has_many :representatives, :order => :last_name, :dependent => :destroy
  has_many :governing_periods, :order => :start_date, :dependent => :destroy

  has_and_belongs_to_many :promises, uniq: true

  validates_uniqueness_of :name, :external_id
  validates_presence_of :name, :external_id

  friendly_id :external_id, :use => :slugged

  image_accessor :image
  attr_accessible :image, :name

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
    !!governing_periods.for_date(date).first
  end

  def large_logo
    image_with_fallback.strip.url
  end

  def default_image
    default_logo = Rails.root.join("app/assets/images/party_logos/unknown_logo_large.jpg")
    large_logo = Rails.root.join("app/assets/images/party_logos/#{URI.encode external_id}_logo_large.jpg")

    large_logo.exist? ? large_logo : default_logo
  end
end
