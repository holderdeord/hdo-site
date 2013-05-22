module AnswersHelper
  def class_for_status(status)
    case status
    when 'approved'
      'success'
    when 'pending'
      'warning'
    when 'rejected'
      'important'
    else
      'info'
    end
  end

  def explanation_for_status(status)
    I18n.t "app.answers.status_text.#{status}"
  end
end