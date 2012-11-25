# encoding: utf-8
require 'spec_helper'

describe Issue do
  let(:blank_issue) { Issue.new }
  let(:valid_issue) { Issue.make! }

  it "is invalid without a title" do
    t = blank_issue

    t.should_not be_valid
    t.title = "foo"
    t.should be_valid
  end

  it "can add categories" do
    a = Category.make!
    b = Category.make!

    t = valid_issue

    t.categories << a
    t.categories << b

    t.categories.map(&:name).sort.should == [a.name, b.name]

    t.should be_valid
  end

  it 'validates status strings' do
    issue = valid_issue

    issue.status = 'published'
    issue.should be_valid

    issue.status = 'in_progress'
    issue.should be_valid

    issue.status = 'shelved'
    issue.should be_valid

    issue.status = 'foobar'
    issue.should_not be_valid
  end

  it 'has in_progress status by default' do
    blank_issue.status.should == 'in_progress'
  end

  it "won't add the same category twice" do
    cat = Category.make!

    valid_issue.categories << cat
    valid_issue.categories << cat

    valid_issue.categories.size.should == 1
  end

  it "can add promises" do
    valid_issue.promise_connections.create!(promise: Promise.make!, status: 'related')
    valid_issue.promises.first.body.should_not be_empty
  end

  it "won't add the same promise twice" do
    promise = Promise.make!

    valid_issue.promise_connections.create!(promise: promise, status: 'related')

    expect {
      valid_issue.promise_connections.create!(promise: promise, status: 'related')
    }.to raise_error(ActiveRecord::RecordInvalid)

    valid_issue.promises.size.should == 1
  end

  it "can add topics" do
    topic = Topic.make!

    valid_issue.topics << topic
    valid_issue.topics.first.should == topic
  end

  it "won't add the same topic twice" do
    topic = Topic.make!

    valid_issue.topics << topic
    valid_issue.topics << topic

    valid_issue.topics.size.should == 1
  end

  it "can add votes with a vote connection" do
    vote = Vote.make!
    issue = Issue.make!(vote_connections: [])

    issue.vote_connections.create!(vote: vote, matches: true)
    issue.votes.should == [vote]

    issue.connection_for(vote).should_not be_nil
  end

  it 'destroys vote connections when destroyed' do
    issue = Issue.make!
    issue.vote_connections.size.should == VoteConnection.count

    issue.destroy
    VoteConnection.count.should == 0
  end

  it "has a unique title" do
    Issue.make!(:title => 'a')
    Issue.make(:title => 'a').should_not be_valid
  end

  it "has a stats object" do
    valid_issue.stats.should be_kind_of(Hdo::Stats::VoteScorer)
  end

  it 'caches the stats object' do
    Hdo::Stats::VoteScorer.should_receive(:new).once

    Issue.find(valid_issue.id).stats # 1 - not cached
    Issue.find(valid_issue.id).stats # 2 - cached
  end

  it 'deletes the cached stats on save' do
    Hdo::Stats::VoteScorer.should_receive(:new).twice

    Issue.find(valid_issue.id).stats # 1 - not cached
    Issue.find(valid_issue.id).stats # 2 - cached

    valid_issue.vote_connections.create! :vote => Vote.make!, :matches => true

    Issue.find(valid_issue.id).stats # 3 - no longer cached
  end

  it 'correctly downcases a title with non-ASCII characters' do
    Issue.make(:title => "Øke ditt og datt").downcased_title.should == "øke ditt og datt"
  end

  it 'finds the latest issues based on vote time' do
    i1 = Issue.make!
    i2 = Issue.make!
    i3 = Issue.make!

    i1.vote_connections.map { |e| e.vote.update_attributes!(:time => 3.days.ago) }
    i2.vote_connections.map { |e| e.vote.update_attributes!(:time => 2.days.ago) }
    i3.vote_connections.map { |e| e.vote.update_attributes!(:time => 1.day.ago) }

    Issue.vote_ordered.should == [i3, i2, i1]
  end

  it 'has a #status_text' do
    i = Issue.make!
    i.status_text.should be_kind_of(String)
  end

  it 'can add who last updated the issue' do
    u = User.make!
    i = Issue.make!

    i.last_updated_by = u
    i.save!

    Issue.first.last_updated_by.should == u
  end

  it 'fetches the name of who last updated the issue' do
    u = User.make!
    i = Issue.make!

    i.last_updated_by_name.should be_kind_of(String)
    i.last_updated_by = u
    i.last_updated_by_name.should == u.name
  end

  describe 'optimistic locking' do
    before(:each) do
      @issue = Issue.make!
      @same_issue = Issue.find(@issue.id)
    end

    it 'prevents saving a stale object' do
      @issue.updated_at = 1.day.from_now
      @issue.save
      expect_stale_object_error_when_updating @same_issue
    end

    it 'is locked when updating category associations' do
      attributes = {
        'category_ids' => [Category.make!.id.to_s]
      }

      update_attributes_on @issue, {issue: attributes}
      expect_stale_object_error_when_updating @same_issue
    end

    it 'is locked when updating topic associations' do
      attributes = {
        'topic_ids' => [Topic.make!.id.to_s]
      }

      update_attributes_on @issue, {issue: attributes}
      expect_stale_object_error_when_updating @same_issue
    end

    it 'is locked when adding a vote connection' do
      votes = {
        Vote.make!.id => {
          direction: 'for',
          weight: 1.0,
          title: 'more cowbell'
        }
      }
      update_attributes_on @issue, {votes: votes}
      expect_stale_object_error_when_updating @same_issue
    end
    
    it 'is locked when adding a promise connection' do
      promise = Promise.make!
      
      attributes = {
        promise.id => {status: 'for'}
      }

      update_attributes_on @issue, {promises: attributes}
      expect_stale_object_error_when_updating @same_issue
    end

    

    it 'is locked when changing proposition type of an existing vote' do
      @issue.vote_connections.create! :vote => Vote.make!, :matches => true, :title => 'hello', :weight => 1.0
      vote = @issue.votes.first

      @issue.save
      @same_issue.reload

      votes = {
        vote.id => {
          direction: 'for',
          weight: 1.0,
          title: 'hello',
          proposition_type: Vote::PROPOSITION_TYPES.first
        }
      }
      update_attributes_on @issue, {votes: votes}
      expect_stale_object_error_when_updating @same_issue
    end

    def expect_stale_object_error_when_updating(issue)
      issue.last_updated_by = User.make!
      lambda { issue.save }.should raise_error(ActiveRecord::StaleObjectError)
    end

    def update_attributes_on(issue, params)
      Hdo::IssueUpdater.new(issue, params, User.make!).update!
    end

  end
end
