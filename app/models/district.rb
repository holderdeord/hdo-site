class District < ActiveRecord::Base
  extend FriendlyId
  include Hdo::ModelHelpers::HasRepresentatives

  has_many :representatives, :order => :last_name
  validates_uniqueness_of :name

  friendly_id :name, :use => :slugged

  def should_generate_new_friendly_id?
    new_record?
  end
end
