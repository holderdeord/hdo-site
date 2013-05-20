class Question < ActiveRecord::Base
  include Workflows::BaseQuestionAndAnswerWorkflow

  attr_accessible :body, :from_name, :from_email, :representative, :representative_id,
                  :issues, :show_sender

  belongs_to :representative
  has_one    :answer, dependent: :destroy
  has_and_belongs_to_many :issues, uniq: true, order: "updated_at DESC"

  validates :body,           presence: true
  validates :from_name,      presence: true
  validates :from_email,     email: true
  validates :representative, presence: true
  validates :answer,         associated: true

  scope :answered,   -> { joins(:answer) }
  scope :unanswered, -> { where('(select count(*) from answers where question_id = questions.id) = 0') }

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
end
