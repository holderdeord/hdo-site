require 'spec_helper'

module Hdo
  module Utils
    describe OverrideMailRecipient do
      let(:mail) { double(to: ["representative@example.com"]) }

      it 'should change recipient to the test account' do
        mail.should_receive(:to=).with('test+representative_example.com@holderdeord.no')
        OverrideMailRecipient.delivering_email mail
      end

      it 'is registered as an interceptor' do
        OverrideMailRecipient.should_receive(:delivering_email).with(mail)
        Mail.inform_interceptors(mail)
      end

    end
  end
end
