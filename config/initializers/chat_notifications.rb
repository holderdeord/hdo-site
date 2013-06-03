require 'hdo/chat_notifications'

if AppConfig.chat_notifications_enabled && !AppConfig.hipchat_api_token.blank?
  Hdo::ChatNotifications.init
end
