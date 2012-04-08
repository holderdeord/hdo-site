class Vote < ActiveRecord::Base
  belongs_to :issue
  
  has_many :vote_results, :dependent => :delete_all
  has_many :representatives, :through => :vote_results, :order => :last_name
  
  def human_time
    time.strftime("%Y-%m-%d")
  end
  
  def human_enacted
    enacted? ? I18n.t('app.yes') : I18n.t('app.no')
  end
  
  def percent_for
    for_count * 100 / vote_results.count
  end
  
  def percent_against
    against_count * 100 / vote_results.count
  end
  
  def percent_missing
    missing_count * 100 / vote_results.count
  end
end
