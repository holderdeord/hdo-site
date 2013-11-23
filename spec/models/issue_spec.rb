# encoding: utf-8
require 'spec_helper'

describe Issue do
  let(:blank_issue) { Issue.new }
  let(:valid_issue) { Issue.make! }

  it 'finds an issue by its to_param' do
    Issue.find(valid_issue.to_param).should == valid_issue
  end

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

    issue.status = 'publishable'
    issue.should be_valid

    issue.status = 'in_progress'
    issue.should be_valid

    issue.status = 'in_review'
    issue.should be_valid

    issue.status = 'foobar'
    issue.should_not be_valid
  end

  it 'has in_progress status by default' do
    blank_issue.status.should == 'in_progress'
  end

  it 'has no published_at by default' do
    blank_issue.published_at.should be_nil
  end

  it "won't add the same category twice" do
    cat = Category.make!

    valid_issue.categories << cat
    valid_issue.categories << cat

    valid_issue.categories.size.should == 1
  end

  it "won't allow adding to frontpage unless status is 'published'" do
    (Issue::STATUSES - ['published']).each do |status|
      valid_issue.status = status
      valid_issue.frontpage = true

      valid_issue.should_not be_valid
    end
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

  it "can add tags" do
    valid_issue.tag_list << 'some-tag'
    valid_issue.save

    valid_issue.tags.first.name.should == 'some-tag'
  end

  it "won't add the same tag twice" do
    valid_issue.tag_list << 'some-tag'
    valid_issue.tag_list << 'some-tag'
    valid_issue.save

    valid_issue.tags.size.should == 1
  end

  it "can add propositions with a proposition connection" do
    prop = Proposition.make!
    issue = Issue.make!(proposition_connections: [])

    issue.proposition_connections.create!(proposition: prop)
    issue.propositions.should == [prop]
  end

  it 'destroys proposition connections when destroyed' do
    issue = Issue.make!
    issue.proposition_connections.size.should == PropositionConnection.count

    issue.destroy
    PropositionConnection.count.should == 0
  end

  it "has a unique title" do
    Issue.make!(:title => 'a')
    Issue.make(:title => 'a').should_not be_valid
  end

  it 'correctly downcases a title with non-ASCII characters' do
    Issue.make(:title => "Øke ditt og datt").downcased_title.should == "øke ditt og datt"
  end

  it 'correctly downcases a title with trailing whitespace' do
    Issue.make(:title => " Øke ditt og datt").downcased_title.should == "øke ditt og datt"
  end

  it 'finds frontpage issues' do
    i1 = Issue.make!(status: "published", frontpage: false)
    i2 = Issue.make!(status: "published", frontpage: false)
    i3 = Issue.make!(status: "published", frontpage: true)
    i4 = Issue.make!(status: "in_review", frontpage: false)

    data = Issue.for_frontpage(3).map { |e| [e.status, e.frontpage?] }

    data.should == [
      ['published', true],
      ['published', false],
      ['published', false]
    ]
  end

  it 'finds the correct position for the given party' do
    p1 = Party.make!
    p2 = Party.make!
    p3 = Party.make!

    issue = Issue.make!

    x1 = issue.positions.create!(parties: [p1], title: 'a', description: 'b')
    x2 = issue.positions.create!(parties: [p2], title: 'a', description: 'b')

    issue.position_for(p1).should == x1
    issue.position_for(p2).should == x2
    issue.position_for(p3).should be_nil
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

  describe 'next and previous' do
    it "should provide previous and next issues" do
      t1 = Issue.make! title: 'aaaa1', status: 'published'
      t2 = Issue.make! title: 'aaaa2', status: 'published'
      t3 = Issue.make! title: 'aaaa3', status: 'published'

      left, right = t2.previous_and_next

      left.should eq t1
      right.should eq t3
    end

    it "uses the given scope" do
      t1 = Issue.make! title: 'aaaa1', status: 'published'
      t2 = Issue.make! title: 'aaaa2', status: 'published'
      t3 = Issue.make! title: 'aaaa3', status: 'in_progress'

      left, right = t2.previous_and_next(policy: mock(scope: Issue.published))

      left.should == t1
      right.should be_nil
    end
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

    it 'is locked when updating tag associations' do
      attributes = {
        'tag_list' => 'foo,bar'
      }

      update_attributes_on @issue, {issue: attributes}
      expect_stale_object_error_when_updating @same_issue
    end

    it 'is locked when adding a proposition connection' do
      propositions = {
        Proposition.make!.id => {
          connected: 'true',
          title: 'more cowbell'
        }
      }
      update_attributes_on @issue, {propositions: propositions}
      expect_stale_object_error_when_updating @same_issue
    end

    it 'is locked when adding a promise connection' do
      promise = Promise.make!

      attributes = {
        promise.id => {status: 'related'}
      }

      update_attributes_on @issue, {promises: attributes}
      expect_stale_object_error_when_updating @same_issue
    end

    it 'is locked when changing proposition type of an existing proposition' do
      @issue.proposition_connections.create! proposition: Proposition.make!, title: 'hello'
      prop = @issue.propositions.first

      @issue.save
      @same_issue.reload

      propositions = {
        prop.id => {
          connected: 'true',
          title: 'hello',
          proposition_type: PropositionConnection::PROPOSITION_TYPES.first
        }
      }
      update_attributes_on @issue, {propositions: propositions}
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
