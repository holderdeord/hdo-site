class Topic < ActiveRecord::Base
  extend FriendlyId

  attr_accessible :description, :title, :category_ids, :promise_ids, :field_ids
  validates_presence_of :title
  validates_uniqueness_of :title

  has_and_belongs_to_many :fields
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :promises

  has_many :vote_directions
  has_many :votes, :through => :vote_directions, :order => :time

  friendly_id :title, :use => :slugged

  attr_writer :current_step

  def steps
    %w[categories promises votes fields]
  end

  def current_step
    @current_step || steps.first
  end

  def next_step!
    self.current_step = steps[steps.index(current_step) + 1]
  end

  def previous_step!
    self.current_step = steps[steps.index(current_step) - 1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def stats
    @stats ||= Hdo::Stats::TopicCounts.new(self)
  end

  def vote_for?(vote_id)
    vote_directions.any? { |vd| vd.matches? && vd.vote_id == vote_id  }
  end

  def vote_against?(vote_id)
    vote_directions.any? { |vd| !vd.matches? && vd.vote_id == vote_id }
  end

  def connected_to?(vote)
    vote_directions.where(:vote_id => vote.id).any?
  end

  def current_step?(step)
    step == self.current_step
  end
end
