class Field < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :name
  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :topics

  friendly_id :name, :use => :slugged
end
