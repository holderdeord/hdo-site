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

  it 'has a unique body' do
    promise = Promise.make!(:body => 'body')
    Promise.make(:body => promise.body).should_not be_valid
  end

  it 'has party names' do
    parties = [Party.make!(:name => 'A'), Party.make!(:name => 'B')]
    promise = Promise.make!(:parties => parties)

    I18n.with_locale do
      promise.party_names.should == 'A og B'
    end
  end

end