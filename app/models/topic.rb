class Topic < ActiveRecord::Base
  attr_accessible :description, :title, :category_ids, :promise_ids
  validates_presence_of :title

  has_and_belongs_to_many :fields
  has_and_belongs_to_many :categories
  has_and_belongs_to_many :promises

  has_many :vote_directions
  has_many :votes, :through => :vote_directions, :order => :time

  def steps
    %w[categories promises votes]
  end

  def current_step
  	@current_step || steps.first
  end

  attr_writer :current_step

  def next_step
  	self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
  	self.current_step = steps[steps.index(current_step)-1]
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

  def is_vote_for?(vote_id)
    vote_directions.collect {|vd| vd.vote.id if vd.matches}.include?(vote_id)
  end
  
  def is_vote_against?(vote_id)
    vote_directions.collect {|vd| vd.vote.id unless vd.matches}.include?(vote_id)
  end
end
