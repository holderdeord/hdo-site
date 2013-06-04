class Question < ActiveRecord::Base
  include Workflows::BaseQuestionAndAnswerWorkflow

  attr_accessible :body, :from_name, :from_email, :representative, :representative_id,
                  :issues, :show_sender, :internal_comment

  belongs_to :representative
  has_one    :answer, dependent: :destroy
  has_and_belongs_to_many :issues, uniq: true, order: "updated_at DESC"
  has_many :email_events, as: :email_eventable, order: "created_at DESC"

  validates :body,           presence: true
  validates :from_name,      presence: true
  validates :from_email,     email: true
  validates :representative, presence: true
  validates :answer,         associated: true
  validate :answer_comes_from_asked_representative

  scope :answered,             -> { joins(:answer) }
  scope :unanswered,           -> { where('(select count(*) FROM answers WHERE question_id = questions.id) = 0') }
  scope :not_ours,             -> { where("from_email NOT LIKE '%holderdeord.no'")}
  scope :answered_or_not_ours, -> { where("from_email NOT LIKE '%holderdeord.no' OR EXISTS (select 1 FROM answers WHERE question_id = questions.id)")}
  scope :with_pending_answers, -> { answered.where('answers.status = ?', 'pending') }

  def self.all_by_status
    grouped = all.group_by { |q| q.status }
    grouped.values.each do |qs|
      qs.sort_by! { |e| e.created_at }
    end

    grouped
  end

  def self.statuses
    workflow_spec.state_names.map &:to_s
  end

  def answered?
    not answer.nil?
  end

  def teaser
    body.truncate(100)
  end

  def from_display_name
    show_sender? ? from_name : from_initials
  end

  def status_text
    I18n.t "app.questions.status.#{status}"
  end

  private

  def from_initials
    from_name.split(/\W/).map { |e| "#{e[0]}." }.join(' ')
  end

  def answer_comes_from_asked_representative
    if answer && answer.representative != representative
      errors.add(:representative, :must_match_question_representative)
    end
  end
end
