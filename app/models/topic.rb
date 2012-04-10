class Topic < ActiveRecord::Base
  has_and_belongs_to_many :issues
  has_and_belongs_to_many :promises

  acts_as_tree :order => :name

  validates_uniqueness_of :name
end
