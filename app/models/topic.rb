class Topic < ActiveRecord::Base
  extend FriendlyId
  include Hdo::ModelHelpers::HasFallbackImage

  attr_accessible :name, :issue_ids, :image
  validates_presence_of :name
  validates_uniqueness_of :name

  has_and_belongs_to_many :issues, uniq: true
  has_many :promises, through: :issues

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

  def previous_and_next(opts = {})
    topics = self.class.order(opts[:order] || :name)

    current_index = topics.index(self)

    prev_topic = topics[current_index - 1] if current_index > 0
    next_topic = topics[current_index + 1] if current_index < topics.size

    [prev_topic, next_topic]
  end

  def default_image
    "#{Rails.root}/app/assets/images/topic_icons/snakkeboble_venstre.png"
  end

  def downcased_name
    UnicodeUtils.downcase name
  end

end
