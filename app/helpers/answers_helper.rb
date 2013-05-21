module AnswersHelper
  def label_for_status(status)
    klass = 'label '

    case status
    when 'approved'
      klass << 'label-success'
    when 'pending'
      klass << 'label-warning'
    when 'rejected'
      klass << 'label-important'
    end

    klass
  end

  def explanation_for_status(status)
    I18n.t "app.answers.status_text.#{status}"
  end
end