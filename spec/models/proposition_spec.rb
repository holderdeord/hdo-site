require 'spec_helper'

describe Proposition do

  it 'has a valid blueprint' do
    Proposition.make.should be_valid
  end

  it 'is invalid without a body' do
    Proposition.make(body: nil).should_not be_valid
  end

  it 'is invalid without a unique external id' do
    invalid = Proposition.make

    invalid.external_id = Proposition.make!.external_id
    invalid.should_not be_valid
  end

  it "can have a large body" do
    body = "a" * 150_000

    prop = Proposition.make(body: body, description: "a")
    prop.save!

    prop.body.should == body
  end

  it '#plain_body removes HTML' do
    plain = Proposition.make(body: "<p>foo</p>").plain_body
    plain.should == 'foo'
  end

  it '#short_body limits body to 100 characters' do
    prop = Proposition.make(body: "foo")
    prop.short_body.should == "foo"

    prop.body = "a"*300
    prop.short_body.should == "#{('a'*197)}..."

    prop.body = 'a'*200
    prop.short_body.should == prop.body
  end

  it 'has a default pending status' do
    prop = Proposition.new
    prop.status.should == 'pending'
    prop.should be_pending
  end

  it 'can have "published" status' do
    prop = Proposition.make(status: 'published')
    prop.status.should == 'published'
    prop.should be_published
  end

  it 'validates status' do
    Proposition.make(status: 'foo').should_not be_valid
  end

end
