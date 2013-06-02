# encoding: UTF-8

class ModerationMailer < ActionMailer::Base
  layout 'hdo_mail'
  default bcc:      AppConfig.default_bcc_email,
          from:     AppConfig.question_answer_email

  def question_approved_user_email(question)
    @question = question
    with_event mail(to:       question.from_email,
         subject:  'Ditt spørsmål er godkjent',
         reply_to: reply_to_address(question))
  end

  def question_approved_representative_email(question)
    @question = question
    with_event mail(to:       question.representative.email,
         subject:  'Du har fått et nytt spørsmål',
         reply_to: reply_to_address(question))
  end

  def answer_approved_user_email(question)
    @question = question
    with_event mail(to:       question.from_email,
         subject:  "Ditt spørsmål er besvart",
         reply_to: reply_to_address(question))
  end

  private

  def reply_to_address(question)
    "sporsmalsvar+#{question.id}@holderdeord.no"
  end

  def with_event(message)
    @question.email_events.create(
      email_address: message.to.first,
      email_type:    message.subject)
    message
  end

end
