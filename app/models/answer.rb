class Answer < ActiveRecord::Base
  include Workflows::BaseQuestionAndAnswerWorkflow

  attr_accessible :body, :representative_id, :representative, :question, :question_id, :status

  belongs_to :question, touch: true
  belongs_to :representative

  validates :body,           presence: true
  validates :representative, presence: true
  validates :question,       presence: true

  validate :question_is_approved

  def self.all_by_status
    grouped = all.group_by { |a| a.status }
    grouped.values.each do |answers|
      answers.sort_by! { |e| e.created_at }
    end

    grouped
  end

  def self.statuses
    workflow_spec.state_names.map &:to_s
  end

  def party
    representative.party_at created_at
  end

  def status_text
    I18n.t "app.questions.status.#{status}"
  end

  private

  def question_is_approved
    if question && !question.approved?
      # TODO: i18n
      errors.add :question, "must be approved (status=#{question.status})"
    end
  end
end
