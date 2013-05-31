module Hdo
  class Mailer < Devise::Mailer
    default bcc:      'test@holderdeord.no',
            reply_to: 'kontakt@holderdeord.no'

    def devise_mail(record, action, opts={})
      initialize_from_record(record)
      mail(headers_for(action, opts)) do |format|
        format.text
        format.html
      end
    end
  end
end
