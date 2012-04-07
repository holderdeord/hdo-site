class Topic < ActiveRecord::Base
  acts_as_tree :order => :name
  validates_uniqueness_of :name
end
