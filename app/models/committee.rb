class Committee < ActiveRecord::Base
  has_and_belongs_to_many :representatives
  has_many :issues

  validates_uniqueness_of :name
end
