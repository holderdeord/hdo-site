class Field < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :name, :topic_ids, :image
  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :topics

  friendly_id :name, :use => :slugged

  image_accessor :image

  def default_image 
    "#{Rails.root}/app/assets/images/field_icons/snakkeboble_venstre.png"
  end

  def image_with_fallback
    self.image = Pathname.new(default_image) if self.image_uid == nil 
    self.save! if self.image_uid_changed?
    self.image
  end

end
