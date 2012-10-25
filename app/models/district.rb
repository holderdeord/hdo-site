class District < ActiveRecord::Base
  extend FriendlyId
  include Hdo::Model::HasRepresentatives

  attr_accessible :name

  has_many :representatives, order: :last_name

  validates :name,        presence: true, uniqueness: true
  validates :external_id, presence: true, uniqueness: true

  friendly_id :name, use: :slugged
end
