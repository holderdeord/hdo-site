class Representative < ActiveRecord::Base
  belongs_to :party
  belongs_to :district

  has_many :vote_results
  has_many :votes, :through => :vote_results
  has_many :propositions
  has_and_belongs_to_many :committees, :order => :name

  validates_uniqueness_of :first_name, :scope => :last_name # TODO: :scope => :period ?!

  extend FriendlyId
  friendly_id :external_id, :use => :slugged

  def should_generate_new_friendly_id?
    new_record?
  end

  def image
    default = "representatives/unknown.jpg"
    rep = "representatives/#{URI.encode external_id}.jpg"

    if File.exist?(File.join("#{Rails.root}/app/assets/images", rep))
      rep
    else
      default
    end
  end

  def display_name
    "#{last_name}, #{first_name}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def alternate_text
    alternate? ? I18n.t("app.yes") : I18n.t("app.no")
  end

  def age
    dob = date_of_birth or return -1

    if date_of_death
      now = date_of_death
    else
      now = Time.now
    end

    now = now.utc.to_date

    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def stats
    Hdo::Stats::RepresentativeCounts.new self
  end
end
