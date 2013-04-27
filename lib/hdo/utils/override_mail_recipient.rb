module Hdo
  module Utils
    class OverrideMailRecipient
      def self.delivering_email(mail)
        mail.to = anon_email(mail.to.first)
      end

      def self.anon_email(email)
        email['@'] = '_'
        "test+#{email}@holderdeord.no"
      end
    end
  end
end