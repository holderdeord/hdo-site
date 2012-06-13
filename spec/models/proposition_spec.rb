require 'spec_helper'

describe Proposition do
  it "can have a large body" do
    body = "a" * 150_000

    prop = Proposition.new(:body => body)
    prop.save!

    prop.body.should == body
  end
end
