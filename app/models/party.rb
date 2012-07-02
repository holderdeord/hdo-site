class Party < ActiveRecord::Base
  include Hdo::ModelHelpers::HasRepresentatives

  has_many :representatives, :order => :last_name
  has_many :promises

  validates_uniqueness_of :name
  validates_presence_of :name
end
