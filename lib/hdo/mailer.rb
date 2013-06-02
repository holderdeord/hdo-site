module Hdo
  class Mailer < Devise::Mailer
    layout 'hdo_mail'
    default bcc:      AppConfig.default_bcc_email,
            reply_to: AppConfig.default_reply_to_email

    def devise_mail(record, action, opts={})
      initialize_from_record(record)
      mail(headers_for(action, opts)) do |format|
        format.text
        format.html
      end
    end
  end
end
