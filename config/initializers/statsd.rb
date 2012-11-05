require 'hdo/instrumentation'

Hdo::Instrumentation.init if AppConfig.statsd_enabled
