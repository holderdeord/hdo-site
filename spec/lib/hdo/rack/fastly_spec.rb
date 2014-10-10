require 'hdo/rack/fastly'
require 'i18n'

module Hdo
  module Rack
    describe Fastly do
      let(:response) { [200, {}, [""]] }
      let(:app) { double(:app, call: response) }
      let(:fastly) { Fastly.new(app) }

      it 'sets HTTPS=on for HTTP_FASTLY_SSL' do
        app.should_receive(:call).with hash_including('HTTPS' => 'on')
        fastly.call('HTTP_FASTLY_SSL' => "1")
      end

      it 'sets HTTPS=on for HTTP_X_FORWARDED_PROTO=https' do
        app.should_receive(:call).with hash_including('HTTPS' => 'on')
        fastly.call('HTTP_X_FORWARDED_PROTO' => "https")
      end

      it 'does not set HTTPS=on for HTTP_X_FORWARDED_PROTO=http' do
        app.should_not_receive(:call).with hash_including('HTTPS' => 'on')
        fastly.call('HTTP_X_FORWARDED_PROTO' => "http")
      end

      it 'removes Set-Cookie if Cache-Control includes public' do
        response[1] = {
          'Cache-Control' => 'max-age=300, public',
          'Set-Cookie'    => 'foo=bar'
        }

        code, headers, body = fastly.call({})
        headers.should_not have_key('Set-Cookie')
      end
    end
  end
end
