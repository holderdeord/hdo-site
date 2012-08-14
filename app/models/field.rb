class Field < ActiveRecord::Base
  extend FriendlyId
  include Hdo::ModelHelpers::HasFallbackImage

  attr_accessible :name, :topic_ids, :image
  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :topics
  has_many :promises, :through => :topics

  friendly_id :name, :use => :slugged

  image_accessor :image

  def self.column_groups
    all = order(:name)

    column_count = 3

    if all.size < column_count
      [all.to_a]
    else
      all.each_slice(all.size / column_count).to_a
    end
  end

  def default_image
    "#{Rails.root}/app/assets/images/field_icons/snakkeboble_venstre.png"
  end

  def downcased_name
    UnicodeUtils.downcase name
  end

end
