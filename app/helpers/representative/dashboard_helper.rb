module Representative::DashboardHelper
  def label_for(question)
    label = 'label '

    if question.answer.nil?
      label << 'label-important'
    elsif question.answer.rejected?
      label << 'label-important'
    elsif question.answer.approved?
      label << 'label-success'
    else
      label << 'label-warning'
    end

    label
  end

  def label_text_for(question)
    if question.answer.nil?
      I18n.t('app.answers.status.no_answer')
    else
      I18n.t("app.answers.status.#{question.answer.status}")
    end
  end
end