class Committee < ActiveRecord::Base
  extend FriendlyId

  has_and_belongs_to_many :representatives
  has_many :issues, :order => :last_update

  validates_uniqueness_of :name

  friendly_id :external_id, :use => :slugged
end
