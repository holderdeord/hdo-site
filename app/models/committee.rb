class Committee < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :name

  has_many :committee_memberships, dependent: :destroy
  has_many :representatives, through: :committee_memberships
  has_many :parliament_issues, order: :last_update

  validates_uniqueness_of :name # :external_id

  friendly_id :external_id, use: :slugged
end
