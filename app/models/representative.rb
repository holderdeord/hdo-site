class Representative < ActiveRecord::Base
  extend FriendlyId
  include Hdo::ModelHelpers::HasFallbackImage

  attr_accessible :party, :first_name, :last_name, :committees,
                  :district, :date_of_birth, :date_of_death

  belongs_to :party
  belongs_to :district

  has_many :vote_results
  has_many :votes, :through => :vote_results
  has_many :propositions
  has_and_belongs_to_many :committees, :order => :name

  validates_uniqueness_of :first_name, :scope => :last_name # TODO: :scope => :period ?!

  friendly_id :external_id, :use => :slugged

  image_accessor :image

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

  def default_image
    "#{Rails.root}/app/assets/images/representatives/unknown.jpg"
  end
end
