require 'spec_helper'

describe Promise do
  let(:promise) { Promise.make! }
  let(:promise_without_parties) { Promise.make(parties: []) }
  let(:promise_without_categories) { Promise.make(categories: []) }

  it 'has a valid blueprint' do
    promise.should be_valid
  end

  it "can have a large body" do
    body = "a" * 300 # > varchar(255)

    prop = Promise.make!(body: body)
    prop.body.should == body
  end

  it 'is invalid without a source' do
    Promise.make(source: nil).should_not be_valid
  end

  it 'is invalid without a body' do
    Promise.make(body: nil).should_not be_valid
  end

  it 'is invalid without at least one category' do
    promise_without_categories.should_not be_valid
  end

  it 'is invalid without an external_id' do
    invalid = Promise.make
    invalid.external_id = nil

    invalid.should_not be_valid
  end

  it 'has a unique body' do
    promise = Promise.make!(body: 'body')
    Promise.make(body: promise.body).should_not be_valid
  end

  it 'has a unique external id' do
    invalid = Promise.make
    invalid.external_id = promise.external_id

    invalid.should_not be_valid
  end

  it 'has party names' do
    parties = [Party.make!(name: 'A'), Party.make!(name: 'B')]
    promise = Promise.make!(parties: parties)

    I18n.with_locale do
      promise.party_names.should == 'A og B'
    end
  end

  it 'can add parties' do
    pr = promise_without_parties

    pr.parties << Party.make!
    pr.parties.size.should == 1
  end

  it "won't add the same party twice" do
    party = Party.make!
    pr = promise_without_parties

    pr.parties << party
    pr.parties << party

    pr.parties.size.should == 1
  end

  it 'can add categories' do
    pr = promise_without_categories

    pr.categories << Category.make!
    pr.categories.size.should == 1
  end

  it "won't add the same category twice" do
    pr = promise_without_categories
    c = Category.make!

    pr.categories << c
    pr.categories << c

    pr.categories.size.should == 1
  end

  it 'can add issues' do
    promise.issues << Issue.make!
    promise.issues.size.should == 1
  end

  it "won't add the same issue twice" do
    issue = Issue.make!

    promise.issues << issue
    promise.issues << issue

    promise.issues.size.should == 1
  end

end