class Committee < ActiveRecord::Base
  extend FriendlyId
  has_and_belongs_to_many :representatives
  has_many :issues, :order => :last_update

  validates_uniqueness_of :name

  friendly_id :external_id, :use => :slugged

  def should_generate_new_friendly_id?
    new_record?
  end
end
