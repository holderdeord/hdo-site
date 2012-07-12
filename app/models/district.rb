class District < ActiveRecord::Base
  extend FriendlyId
  include Hdo::ModelHelpers::HasRepresentatives

  has_many :representatives, :order => :last_name
  validates_uniqueness_of :name

  friendly_id :name, :use => :slugged
end
