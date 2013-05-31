require 'spec_helper'

module Hdo
  describe Mailer do
    let(:rep) { Representative.make! :with_email }

    it "sends confirmation emails as multipart plaintext and html" do
      mail = rep.send_confirmation_instructions

      mail.parts.count.should == 2
      mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
    end

    it "sends reset password emails as multipart plaintext and html" do
      mail = rep.send_reset_password_instructions

      mail.parts.count.should == 2
      mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
    end
  end
end
