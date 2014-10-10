require 'hdo/rack/locale'
require 'i18n'

module Hdo
  module Rack
    describe Locale do
      before { I18n.default_locale = :nb }

      let(:app_headers) { {} }
      let(:app) { double(:app, :call => [200, app_headers, [""]]) }
      let(:locale) { Locale.new(app) }

      it 'should change locale to :nn' do
        env = {
          'HTTP_ACCEPT_LANGUAGE' => 'nn-no,nn;q=0.9,no-no;q=0.8,no;q=0.6,nb-no;q=0.5,nb;q=0.4,en-us;q=0.3,en;q=0.1'
        }

        app.should_receive(:call).with do |env|
          I18n.locale.should == :nn
        end

        status, headers, body = locale.call(env)

        I18n.locale.should == :nb
      end

      it 'should not change locale to :en' do
        env = {
          'HTTP_ACCEPT_LANGUAGE' => 'en-US,en;q=0.8'
        }

        app.should_receive(:call).with do |env|
          I18n.locale.should == :nb
        end

        status, headers, body = locale.call(env)
        I18n.locale.should == :nb
      end

      it 'resets locale on exceptions' do
        app.should_receive(:call).with do |env|
          I18n.locale = :en
        end.and_raise("foo")

        expect {
          locale.call({})
        }.to raise_error

        I18n.locale.should == :nb
      end

      it 'adds a Content-Language header' do
        _, headers, _ = locale.call({})
        headers['Content-Language'].should == I18n.locale.to_s
      end

      it 'adds Vary: Accept-Language' do
        _, headers, _ = locale.call({})
        headers['Vary'].should == 'Accept-Language'
      end

      it 'does not replace existing values in Vary' do
        app_headers.merge!('Vary' => 'Accept-Encoding')
        _, headers, _ = locale.call({})
        headers['Vary'].should == 'Accept-Encoding,Accept-Language'
      end

    end
  end
end
