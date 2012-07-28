class Field < ActiveRecord::Base
  extend FriendlyId
  include Hdo::ModelHelpers::HasFallbackImage

  attr_accessible :name, :topic_ids, :image
  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :topics

  friendly_id :name, :use => :slugged

  image_accessor :image

  def default_image 
    "#{Rails.root}/app/assets/images/field_icons/snakkeboble_venstre.png"
  end

end
