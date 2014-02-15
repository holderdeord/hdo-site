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

  it 'finds the previous and next proposition by vote time' do
    v1 = Vote.make!(time: 1.month.ago)
    v2 = Vote.make!(time: Time.now)
    v3 = Vote.make!(time: 1.month.from_now)

    p1 = Proposition.make!(:votes => [v1])
    p2 = Proposition.make!(:votes => [v2])
    p3 = Proposition.make!(:votes => [v3])

    p1.next.should == p2
    p2.next.should == p3
    p3.next.should be_nil

    p1.previous.should be_nil
    p2.previous.should == p1
    p3.previous.should == p2
  end

  it 'does a source guess' do
    prop = Proposition.make(on_behalf_of: "Party", description: "Proposition from John Doe")
    Hdo::Utils::PropositionSourceGuesser.should_receive(:parties_for).with("#{prop.on_behalf_of} #{prop.description}")

    prop.source_guess
  end

  it 'is interesting by default' do
    proposition = Proposition.make
    proposition.should be_interesting

    proposition.interesting = false
    proposition.should_not be_interesting
  end

  it 'collects parliament issue data (for indexing)' do
    vote = Vote.make!
    i1 = ParliamentIssue.make!(votes: [vote], document_group: 'Foo')
    i2 = ParliamentIssue.make!(votes: [vote], document_group: nil, issue_type: 'Bar')

    prop = Proposition.make!(votes: [vote])
    prop.parliament_issue_document_group_names.should == ['Foo']
    prop.parliament_issue_type_names.should == ['Bar']
  end
end
