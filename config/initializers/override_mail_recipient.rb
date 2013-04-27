unless Rails.env.production?
  require 'hdo/utils/override_mail_recipient'
  ActionMailer::Base.register_interceptor Hdo::Utils::OverrideMailRecipient
end