require 'ostruct'

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

  def percentages
    f, a, m = for_count, against_count, missing_count
    total = f + a + m

    OpenStruct.new(
      :for     => f * 100 / total,
      :against => a * 100 / total,
      :missing => m * 100 / total
    )
  end

end
