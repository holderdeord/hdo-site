require 'spec_helper'

describe Proposition do
  it 'has a valid blueprint' do
    Proposition.make.should be_valid
  end

  it "can have a large body" do
    body = "a" * 150_000

    prop = Proposition.new(:body => body, :description => "a")
    prop.save!

    prop.body.should == body
  end

  it '#plain_body removes HTML' do
    plain = Proposition.make(:body => "<p>foo</p>").plain_body
    plain.should == 'foo'
  end

  it '#short_body limits body to 100 characters' do
    prop = Proposition.make(:body => "foo")
    prop.short_body.should == "foo"

    prop.body = "a"*200
    prop.short_body.should == "#{('a'*97)}..."

    prop.body = 'a'*100
    prop.short_body.should == prop.body
  end
end
