module QuestionsHelper
  def data_representatives
    @representatives.map do |rep|
      { slug: rep.slug, name: rep.name_with_party, district: rep.district.slug, opted_out: rep.opted_out? }
    end
  end

  def question_issue_options
    opts = Issue.search("*", per_page: 1000).map { |e| [e.title, e.id] }
    options_for_select opts, selected: @question.issues.map(&:id)
  end

  def question_status_options
    opts = Question.statuses.map { |status| [t("app.questions.status.#{status}"), status] }
    options_for_select opts, selected: @question.status
  end

  def answer_status_options
    opts = Answer.statuses.map { |status| [t("app.questions.status.#{status}"), status] }
    options_for_select opts, selected: @answer.status
  end

  def alert_class_for_status(status)
    klass = 'alert '

    case status
    when 'approved'
      klass << 'alert-success'
    when 'pending'
      klass << 'alert-info'
    when 'rejected'
      klass << 'alert-warning'
    end

    klass
  end
end