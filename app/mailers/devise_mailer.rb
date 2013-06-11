class DeviseMailer < Devise::Mailer
  layout 'hdo_mail'

  default from:     "Holder de ord <#{AppConfig.question_answer_email}>",
          bcc:      AppConfig.default_bcc_email,
          reply_to: AppConfig.default_reply_to_email

  def devise_mail(record, action, opts={})
    initialize_from_record(record)
    mail(headers_for(action, opts.merge(bracketed_to_email(record)))) do |format|
      format.text
      format.html
    end
  end

  private

  def bracketed_to_email(record)
    { to: "#{record.name} <#{record.email}>" }
  end

end
