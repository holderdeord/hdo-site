module Hdo
  class Mailer < Devise::Mailer
    def devise_mail(record, action, opts={})
      initialize_from_record(record)
      mail(headers_for(action, opts)) do |format|
        format.text
        format.html
      end
    end
  end
end
