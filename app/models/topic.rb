class Topic < ActiveRecord::Base
  acts_as_tree
  validates_uniqueness_of :name
end
