require 'hipchat'

module Hdo
  module ChatNotifications

    def self.client
      @client ||= HipChat::Client.new(AppConfig.hipchat_api_token)
    end

    def self.init
      ActiveSupport::Notifications.subscribe('resource.confirmed') do |event_name, resource|
        begin
          msg = "#{resource.name} har akseptert invitasjonen (#{Rails.env})"
          client['Teknisk'].send('HDO', msg, color: 'green', notify: true)
        rescue
          Rails.logger.warn "#{self}: failed notification for #{event_name}"
        end
      end
    end
  end
end