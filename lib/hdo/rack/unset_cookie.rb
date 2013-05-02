module Hdo
  module Rack

    #
    # Fastly will ignore beresp's with Set-Cookie even though we set max-age.
    # We'll remove the header here to avoid relying on that being configured in Fastly.
    #

    class UnsetCookie
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)

        if headers['Set-Cookie'] && headers['Cache-Control'] =~ /public/
          headers.delete('Set-Cookie')
        end

        [status, headers, body]
      end

    end
  end
end