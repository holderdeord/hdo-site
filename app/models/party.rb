class Party < ActiveRecord::Base
  extend FriendlyId

  include Hdo::ModelHelpers::HasFallbackImage
  include Hdo::ModelHelpers::HasRepresentatives

  has_many :representatives, :order => :last_name
  has_many :promises

  validates_uniqueness_of :name, :external_id
  validates_presence_of :name, :external_id

  friendly_id :external_id, :use => :slugged

  image_accessor :image
  attr_accessible :image, :name

  def large_logo
    image_with_fallback.strip.url
  end

  def default_image
    default_logo = Rails.root.join("app/assets/images/party_logos/unknown_logo_large.jpg")
    large_logo = Rails.root.join("app/assets/images/party_logos/#{URI.encode external_id}_logo_large.jpg")

    large_logo.exist? ? large_logo : default_logo
  end

end
