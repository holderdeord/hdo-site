class District < ActiveRecord::Base
  include Hdo::ModelHelpers::HasRepresentatives

  has_many :representatives, :order => :last_name
  validates_uniqueness_of :name
end
