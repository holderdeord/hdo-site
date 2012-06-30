class Topic < ActiveRecord::Base
  attr_accessible :description, :title
  validates_presence_of :title

  has_and_belongs_to_many :fields
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :promises
end
