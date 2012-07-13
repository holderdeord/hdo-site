class Party < ActiveRecord::Base
  extend FriendlyId

  include Hdo::ModelHelpers::HasRepresentatives

  has_many :representatives, :order => :last_name
  has_many :promises

  validates_uniqueness_of :name
  validates_presence_of :name

  friendly_id :external_id, :use => :slugged

  def large_logo
    default = "party_logos/unknown_logo_large.jpg"
    party_logo = "party_logos/#{URI.encode external_id}_logo_large.jpg"

    if File.exist?(File.join("#{Rails.root}/app/assets/images", party_logo))
      party_logo
    else
      default
    end
  end

end
