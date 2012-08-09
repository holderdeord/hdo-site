require 'spec_helper'

describe Promise do
  it "can have a large body" do
    body = "a" * 300 # > varchar(255)

    prop = Promise.make!(:body => body)
    prop.body.should == body
  end

  it 'is invalid without a source' do
    Promise.make(:source => nil).should_not be_valid
  end

  it 'is invalid without a body' do
    Promise.make(:body => nil).should_not be_valid
  end

  it 'is invalid without at least one category' do
    Promise.make(:categories => []).should_not be_valid
  end

  it 'has a unique body per party' do
    b1 = 'body1'
    p1 = Party.make!
    p2 = Party.make!

    Promise.make!(:body => b1, :party => p1)

    Promise.make(:body => b1, :party => p1).should_not be_valid
    Promise.make(:body => b1, :party => p2).should be_valid
  end

end