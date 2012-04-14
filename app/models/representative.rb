class Representative < ActiveRecord::Base
  belongs_to :party
  belongs_to :district
  has_and_belongs_to_many :committees, :order => :name

  has_many :vote_results, :reverse_order => :time
  has_many :votes, :through => :vote_results

  validates_uniqueness_of :first_name, :scope => :last_name # TODO: :scope => :period ?!

  def display_name
    "#{last_name}, #{first_name}"
  end

  def alternate_text
    alternate? ? I18n.t("app.yes") : I18n.t("app.no")
  end

  def age
    return -1 if date_of_birth.nil?

    if date_of_death
      now = date_of_death
    else
      now = Time.now
    end

    now = now.utc.to_date
    dob = date_of_birth

    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def stats
    Stats.new vote_results.group_by(&:result)
  end

  class Stats
    def initialize(data)
      @data = data
    end

    def absent_count
      Array(@data[0]).size
    end

    def for_count
      Array(@data[1]).size
    end

    def against_count
      Array(@data[-1]).size
    end

    def absent_percent
      absent_count * 100 / total
    end

    def for_percent
      for_count * 100 / total
    end

    def against_percent
      against_count * 100 / total
    end

    def total
      @total ||= @data.values.flatten.size
    end

  end
end
