class Field < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :name, :topic_ids
  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :topics

  friendly_id :name, :use => :slugged

  def icon
    field_icon = "field_icons/#{URI.encode name}_icon.jpg"
    default = 'field_icons/unknown_icon.jpg'

    if File.exist?(File.join("#{Rails.root}/app/assets/images", field_icon))
      field_icon
    else
      default
    end
  end
end
