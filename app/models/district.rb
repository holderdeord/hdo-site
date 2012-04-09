class District < ActiveRecord::Base
  has_many :representatives, :order => :last_name
  validates_uniqueness_of :name
end
