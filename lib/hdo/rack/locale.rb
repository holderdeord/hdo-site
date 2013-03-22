module Hdo
  module Rack

    #
    # we use our own locale middleware since our behaviour is very simple: respond with :nn if the user asks for it, otherwise :nb
    #

    AVAILABLE       = %w[nb nn]
    ACCEPT_LANGUAGE = 'Accept-Language'

    class Locale
      def initialize(app)
        @app = app
      end

      def call(env)
        I18n.locale = locale_from(env) || I18n.default_locale

        status, headers, body = @app.call(env)
        set_headers(headers)

        [status, headers, body]
      ensure
        I18n.locale = I18n.default_locale
      end

      private

      def set_headers(headers)
        headers['Content-Language'] = I18n.locale.to_s

        keys = (headers['Vary'] || '').split(/[\s,]+/)
        keys << ACCEPT_LANGUAGE unless keys.include?(ACCEPT_LANGUAGE)

        headers['Vary'] = keys.join(',')
      end

      def locale_from(env)
        header = env['HTTP_ACCEPT_LANGUAGE'] or return

        preferred = header.split(",").map { |e| e.split(";q=") }.
                            sort_by { |lang, q| -(q || 1.0).to_f }

        found = preferred.find { |loc, q| AVAILABLE.include?(loc) }
        found.first if found
      rescue
        Rails.logger.warn "unable to parse Accept-Language from: #{header.inspect}"
        nil
      end
    end
  end
end