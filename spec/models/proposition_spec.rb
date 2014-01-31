require 'spec_helper'

describe Proposition do
  before do
    @start = 1.month.ago
    @finish = 1.month.from_now

    @parliament_session = ParliamentSession.make!(start_date: @start, end_date: @finish)
  end

  it 'has a valid blueprint' do
    Proposition.make.should be_valid
  end

  it 'is invalid without a body' do
    Proposition.make(body: nil).should_not be_valid
  end

  it 'is invalid without a unique external id' do
    invalid = Proposition.make

    invalid.external_id = Proposition.make!(:with_vote).external_id
    invalid.should_not be_valid
  end

  it "can have a large body" do
    body = "a" * 150_000

    prop = Proposition.make(:with_vote, body: body, description: "a")
    prop.save!

    prop.body.should == body
  end

  it '#plain_body removes HTML' do
    plain = Proposition.make(body: "<p>foo</p>").plain_body
    plain.should == 'foo'
  end

  it 'has a default pending status' do
    prop = Proposition.new
    prop.status.should == 'pending'
    prop.should be_pending
  end

  it 'can have "published" status' do
    prop = Proposition.make(status: 'published', simple_description: 'foo')
    prop.status.should == 'published'
    prop.should be_published
  end

  it 'can not have "published" status without a simple description' do
    prop = Proposition.make(status: 'published')
    prop.should_not be_valid

    prop.simple_description = 'foo'
    prop.should be_valid
  end

  it 'validates status' do
    Proposition.make(status: 'foo').should_not be_valid
  end

  it 'has a parliament session' do
    prop = Proposition.make(votes: [Vote.make(time: Time.now)])

    prop.parliament_session.should == @parliament_session
    prop.parliament_session_name.should == "#{@start.year}-#{@finish.year}"
  end

  it 'has a published scope' do
    published = Proposition.make!(status: 'published', simple_description: 'foo')
    _         = Proposition.make!(status: 'pending')

    Proposition.published.should == [published]
  end

  it 'can not have an empty simple description or body' do
    Proposition.make(simple_description: '').should_not be_valid
    Proposition.make(simple_body: '').should_not be_valid
  end

  it 'can add proposers' do
    proposers   = [Party.make!, Representative.make!]
    proposition = Proposition.make!

    proposers.each { |proposer| proposition.add_proposer(proposer) }
    proposition.reload.proposers.should == proposers
  end
end
