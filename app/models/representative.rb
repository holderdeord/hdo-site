class Representative < ActiveRecord::Base
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  attr_accessible :email, :password, :password_confirmation, :remember_me
  mount_uploader :image, RepresentativeUploader

  extend FriendlyId

  include Tire::Model::Search
  include Tire::Model::Callbacks
  extend Hdo::Search::Index

  tire.settings(TireSettings.default) {
    mapping do
      indexes :district do
        indexes :name, type: :string
      end

      indexes :latest_party do
        indexes :name, type: :string
        indexes :slug, type: :string
      end

      indexes :full_name, index: :not_analyzed
      indexes :last_name, index: :not_analyzed
      indexes :first_name, index: :not_analyzed
      indexes :slug
    end
  }

  update_index_on_change_of :district, :parties, has_many: true
  update_index_on_change_of :party_memberships

  attr_accessible :first_name, :last_name, :committees, :district,
                  :date_of_birth, :date_of_death, :twitter_id, :email,
                  :attending

  default_scope order: :last_name

  belongs_to :district

  has_many :vote_results, dependent: :destroy
  has_many :votes,        through:   :vote_results
  has_many :propositions

  has_many :party_memberships, dependent: :destroy
  has_many :parties,           through: :party_memberships

  has_many :committee_memberships, dependent: :destroy
  has_many :committees,            through: :committee_memberships

  has_many :questions
  has_many :answers

  validates_uniqueness_of :first_name, scope: :last_name # TODO: scope: :period ?!

  validates :external_id, presence: true, uniqueness: true
  validates :email,       allow_nil: true, uniqueness: true, email: true
  validates :twitter_id,  allow_nil: true, uniqueness: true, format: /^[^@]/

  scope :attending,  -> { where(attending: true) }
  scope :with_email, -> { where('email IS NOT NULL') }

  friendly_id :external_id, use: :slugged

  def self.cached
    Rails.cache.fetch('representative/all') { Representative.all.to_a }
  end

  def unconfirmed_email
    email unless confirmed?
  end

  def only_if_unconfirmed
    pending_any_confirmation { yield }
  end

  def attempt_set_password(params)
    attrs = {
      password:              params[:password],
      password_confirmation: params[:password_confirmation]
    }
    update_attributes(attrs)
  end
  # new function to return whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  def display_name
    "#{last_name}, #{first_name}"
  end

  def full_name
    "#{first_name} #{last_name}"
  end
  alias_method :name, :full_name

  def name_with_party
    # missing spec
    "#{full_name} (#{latest_party.name})"
  end

  def alternate_text
    alternate? ? I18n.t("app.yes") : I18n.t("app.no")
  end

  def current_party
    party_at Time.current
  end

  def latest_party
    membership = if party_memberships.loaded?
                   party_memberships.sort_by(&:start_date).last
                 else
                   party_memberships.order(:start_date).last
                 end

    membership && membership.party
  end

  def current_party_membership
    party_membership_at Time.current
  end

  def party_at(date)
    membership = party_membership_at(date)
    membership && membership.party
  end

  def party_membership_at(date)
    if party_memberships.loaded?
      # if all the memberships are already loaded, it's faster to check dates in code
      # a better solution would probably be to do a more clever query in Hdo::Stats::VoteScorer#party_percentages_for
      party_memberships.find { |e| e.include?(date) }
    else
      party_memberships.for_date(date).first
    end
  end

  def current_committees
    committees_at Time.current
  end

  def committees_at(date)
    memberships = committee_memberships_at(date)
    memberships.map { |e| e.committee }
  end

  def has_image?
    !image.to_s.include?("unknown")
  end

  def has_twitter?
    twitter_id.present?
  end

  def committee_memberships_at(date)
    if committee_memberships.loaded?
      committee_memberships.select { |e| e.include?(date) }
    else
      committee_memberships.for_date(date)
    end
  end

  def age
    dob = date_of_birth or return -1

    if date_of_death
      now = date_of_death
    else
      now = Date.today
    end

    now = now.to_date

    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
  end

  def twitter_url
    "https://twitter.com/#{twitter_id}" if twitter_id
  end

  def stats
    Hdo::Stats::RepresentativeCounts.new self
  end

  def to_indexed_json
    to_json include: [:district],
            methods: [:latest_party, :full_name],
            only: [:slug, :last_name, :first_name]
  end

  private

  # for devise:

  def email_required?() false end
  def password_required?() false end
  def confirmation_required?() false end
  def postpone_email_change?() false end
  end
