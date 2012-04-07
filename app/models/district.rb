class District < ActiveRecord::Base
  has_many :representatives
  validates_uniqueness_of :name
end
