require 'spec_helper'

describe EmailEvent do
  it "isn't valid with a bad email" do
    EmailEvent.create(email_type: 'something ok', email_address: 'not really an email address').should_not be_valid
  end

  it "isn't valid without an email" do
    EmailEvent.create(email_type: 'something ok').should_not be_valid
  end

  it "is valid with a valid email" do
    EmailEvent.create(email_type: 'something ok', email_address: 'test@test.com').should be_valid
  end

  it "is invalid without a type" do
    EmailEvent.new(email_address: 'test@test.com').should_not be_valid
  end

end
