unless Rails.env.production?
  class OverrideMailRecipient
    def self.delivering_email(mail)
      mail.to = anon_email(mail.to.first)
    end

    def self.anon_email(email)
      email['@'] = '_'
      "hackaton-april+#{email}@holderdeord.no"
    end
  end
  ActionMailer::Base.register_interceptor(OverrideMailRecipient)
end