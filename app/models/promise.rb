class Promise < ActiveRecord::Base
  belongs_to :party
  has_and_belongs_to_many :topics, :order => :name
  
  validates_presence_of :source, :body, :party
  validates_uniqueness_of :body, :scope => :party_id
  
  def general_text
    I18n.t(general? ? 'app.yes' : 'app.no')
  end
  
  def topic_names
    topics.map(&:name)
  end
  
end
