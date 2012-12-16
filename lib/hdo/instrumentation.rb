require 'statsd'

module Hdo
  module Instrumentation
    def self.statsd
      @statsd ||= Statsd.new(AppConfig.statsd_host, AppConfig.statsd_port)
    end

    def self.host
      @host ||= Socket.gethostname.gsub(".", "-")
    end

    def self.init
      ActiveSupport::Notifications.subscribe 'process_action.action_controller' do |*args|
        event      = ActiveSupport::Notifications::Event.new(*args)
        controller = event.payload[:controller]
        action     = event.payload[:action]
        format     = event.payload[:format] || "all"
        format     = "all" if format == "*/*"
        status     = event.payload[:status]

        key = "#{controller}.#{action}.#{format}.#{host}"

        ActiveSupport::Notifications.instrument 'performance',
                                                 action: :timing,
                                                 measurement: "#{key}.total_duration",
                                                 value: event.duration

        ActiveSupport::Notifications.instrument 'performance',
                                                action: :timing,
                                                measurement: "#{key}.db_time",
                                                value: event.payload[:db_runtime]

        ActiveSupport::Notifications.instrument 'performance',
                                                action: :timing,
                                                measurement: "#{key}.view_time",
                                                value: event.payload[:view_runtime]

        ActiveSupport::Notifications.instrument :performance,
                                                measurement: "#{key}.status.#{status}"
      end

      ActiveSupport::Notifications.subscribe 'performance' do |name, start, finish, id, payload|
        action      = payload[:action] || :increment
        measurement = payload[:measurement]
        value       = payload[:value]
        key_name    = "performance.#{measurement}"

        statsd.__send__ action.to_s, key_name, (value || 1)
      end
    end
  end
end