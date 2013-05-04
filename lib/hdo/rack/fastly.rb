module Hdo
  module Rack

    # Middleware to avoid Fastly lock-in
    #
    # 1. Fastly (and Varnish, by default) will ignore beresp's with Set-Cookie even though cache headers are set.
    #    We trust the app and delete the Set-Cookie header if Cache-Control is public
    # 2. Fastly sets "Fastly-SSL: 1" for HTTPS requests.
    #    We translate this to HTTPS=on, which is (one of several alternatives) understood by Rack.
    #

    class Fastly
      HTTPS = 'https'

      def initialize(app)
        @app = app
      end

      def call(env)
        if env['HTTP_FASTLY_SSL'] || env['HTTP_X_FORWARDED_PROTO'] == HTTPS
          env['HTTPS'] = 'on'
        end

        status, headers, body = @app.call(env)

        if headers['Set-Cookie'] && headers['Cache-Control'] =~ /public/
          headers.delete('Set-Cookie')
        end

        [status, headers, body]
      end

    end
  end
end