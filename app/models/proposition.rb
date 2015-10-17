class Proposition < ActiveRecord::Base
  include Hdo::Search::Index

  settings(SearchSettings.default) {
    mappings {
      indexes :description,                           type: :string, analyzer: SearchSettings.default_analyzer
      indexes :plain_body,                            type: :string, analyzer: SearchSettings.default_analyzer
      indexes :simple_description,                    type: :string, analyzer: SearchSettings.default_analyzer
      indexes :simple_body,                           type: :string, analyzer: SearchSettings.default_analyzer
      indexes :on_behalf_of,                          type: :string
      indexes :vote_time,                             type: :date
      indexes :status,                                type: :string,  index: :not_analyzed
      indexes :parliament_session_name,               type: :string,  index: :not_analyzed
      indexes :id,                                    type: :integer, index: :not_analyzed
      indexes :interesting,                           type: :boolean
      indexes :starred,                               type: :boolean
      indexes :committee_names,                       type: :string,  index: :not_analyzed
      indexes :category_names,                        type: :string,  index: :not_analyzed
      indexes :parliament_issue_type_names,           type: :string,  index: :not_analyzed
      indexes :parliament_issue_document_group_names, type: :string,  index: :not_analyzed
      indexes :issue_ids,                             type: :integer, index: :not_analyzed

      indexes :votes do
        indexes :slug,    type: :string, index: :not_analyzed
        indexes :enacted, type: :boolean
      end

      indexes :proposers do
        indexes :external_id, type: :string, index: :not_analyzed
        indexes :name,        type: :string, index: :not_analyzed
      end
    }
  }

  add_index_callbacks partial_update: false

  update_index_on_change_of :votes, has_many: true
  update_index_on_change_of :parliament_issues, has_many: true
  update_index_on_change_of :proposition_connections

  attr_accessible :description, :on_behalf_of, :body, :representative_id,
                  :simple_description, :simple_body, :status,
                  :interesting, :starred

  has_and_belongs_to_many :votes, uniq: true
  has_many :proposition_connections, dependent: :destroy
  has_many :issues, through: :proposition_connections
  has_many :parliament_issues, through: :votes
  has_many :proposition_endorsements, dependent: :destroy

  validates :body, presence: true
  validates :status, presence: true, inclusion: {in: %w[pending published]}
  validates :simple_description, presence: true, if: :published?
  validates :simple_description, length: {minimum: 1, maximum: 255}, allow_nil: true
  validates :simple_body, length: {minimum: 1}, allow_nil: true

  validates_uniqueness_of :external_id, allow_nil: true # https://github.com/holderdeord/hdo-site/issues/138

  scope :published,    -> { where(status: 'published') }
  scope :interesting,  -> { where(interesting: true) }
  scope :vote_ordered, -> { includes(:votes).order('votes.time DESC') }

  def plain_body
    Nokogiri::HTML.parse(body).xpath('//text()').map { |e| e.text.strip }.join(' ')
  end

  TITLE_RULES = {
    /^«(.+?)»$/ => '\\1',
    /^Stortinget ber (regjeringen|regjeringa)/i => 'Be \\1',
    /^Stortinget samtykker i/ => 'Samtykke i',
  }

  def auto_title
    title = plain_body.gsub("\n", " ")

    TITLE_RULES.each do |rx, replacement|
      title.sub!(rx, replacement)
    end

    title.sub!(/^.+? [––] (.+?) [––] (vedlegges protokollen|vert vedlagt protokollen|bifalles ikke|vedtas ikke)/) { |e|
      desc = $1
      action = $2

      desc_words = desc.split(" ")
      new_desc = "#{UnicodeUtils.downcase(desc_words[0])} #{desc_words[1..-1].join(" ")}"

      case action
      when 'bifalles ikke'
        "Ikke bifalle #{new_desc}"
      when 'vedtas ikke'
        "Ikke vedta #{new_desc}"
      else
        "Legge #{new_desc} ved protokollen"
      end
    }

    title = title.split(/(?<!Meld|Prop|Kap|jf|nr|St|\b[A-Z]|\d)[.:]( |$)/).first

    title = "#{title}." unless title.ends_with?(".")

    "#{UnicodeUtils.upcase title[0]}#{title[1..-1]}"
  end

  def vote_time
    @vote_time ||= votes.first.try(:time)
  end

  def parliament_session
    @parliament_session ||= ParliamentSession.for_date(vote_time.to_date)
  end

  def parliament_session_name
    parliament_session.try(:name)
  end

  def pending?
    status == 'pending'
  end

  def published?
    status == 'published'
  end

  def proposers
    proposition_endorsements.map(&:proposer)
  end

  def add_proposer(proposer)
    proposition_endorsements.create!(proposer: proposer)
  end

  def delete_proposer(proposer)
    proposition_endorsements.where(proposer_id: proposer.id, proposer_type: proposer.class.name).destroy_all
  end

  def previous
    return unless v = votes.order(:time).first
    @previous ||= self.class.joins(:votes).where("votes.time < ?", v.time).order('votes.time DESC').first
  end

  def next
    return unless v = votes.order(:time).last
    @next ||= self.class.joins(:votes).where("votes.time > ?", v.time).order('votes.time').first
  end

  def source_guess
    @source_guess ||= Hdo::Utils::PropositionSourceGuesser.parties_for("#{on_behalf_of} #{description}")
  end

  def related_propositions
    related_propositions = parliament_issues.flat_map { |e| e.votes.flat_map(&:propositions) }.uniq
    related_propositions.delete self

    related_propositions
  end

  #
  # for indexing:
  #

  def committees
    parliament_issues.map(&:committee).compact.uniq
  end

  def committee_names
    committees.map(&:name)
  end

  def categories
    parliament_issues.flat_map(&:categories).compact.uniq
  end

  def category_names
    categories.map(&:human_name).compact
  end

  def parliament_issue_type_names
    parliament_issues.map(&:issue_type_name).compact.uniq
  end

  def parliament_issue_document_group_names
    parliament_issues.map(&:document_group_name).compact.uniq
  end

  def issue_ids
    issues.map(&:id)
  end

  def as_indexed_json(options = nil)
    methods = [
      :plain_body,
      :committee_names,
      :category_names,
      :proposers,
      :parliament_issue_type_names,
      :parliament_issue_document_group_names,
      :issue_ids
    ]

    methods += [:parliament_session_name, :vote_time] if votes.any?

    as_json methods: methods,
            include: {votes: {only: [:slug, :enacted]} },
            only:    [:description, :on_behalf_of, :status, :id,
                      :simple_description, :simple_body, :interesting, :starred]
  end
end
