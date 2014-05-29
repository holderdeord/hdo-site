module Hdo
  module Rack

    #
    # Ensures the Date header which is required for some caches.
    # Should be unnecessary with Rails 4.

    class Date

      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)

        unless headers['Date']
          headers['Date'] = Time.now.rfc2822.to_s
        end

        [status, headers, body]
      end

    end
  end
end