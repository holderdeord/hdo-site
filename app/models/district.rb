class District < ActiveRecord::Base
  include Hdo::ModelHelpers::HasRepresentatives

  has_many :representatives, :order => :last_name
  validates_uniqueness_of :name

  extend FriendlyId
  friendly_id :name, :use => :slugged

  def should_generate_new_friendly_id?
    new_record?
  end
end
