class Promise < ActiveRecord::Base
  attr_accessible :party, :general, :categories, :source, :body
  
  belongs_to :party

  has_and_belongs_to_many :categories, :order => :name
  has_and_belongs_to_many :topics, :order => :title

  validates_presence_of :source, :body, :party
  validates_uniqueness_of :body, :scope => :party_id
  validates_length_of :categories, :minimum => 1

  def general_text
    I18n.t(general? ? 'app.yes' : 'app.no')
  end
end
