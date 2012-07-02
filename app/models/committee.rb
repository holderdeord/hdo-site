class Committee < ActiveRecord::Base
  has_and_belongs_to_many :representatives
  has_many :issues, :order => :last_update

  validates_uniqueness_of :name
end
