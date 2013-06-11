require 'spec_helper'

describe DeviseMailer do
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

  it "makes a bracketed email" do
    Hdo::Utils::OverrideMailRecipient.stub!(:delivering_email)
    mail = rep.send_reset_password_instructions
    mail[:to].field.value.should eq "#{rep.name} <#{rep.email}>"
  end
end
