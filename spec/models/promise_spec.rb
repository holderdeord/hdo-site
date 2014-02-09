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

  it 'is invalid without a parliament period' do
    promise = Promise.make(parliament_period: nil)
    promise.should be_invalid

    promise.parliament_period = ParliamentPeriod.make!
    promise.should be_valid
  end

  it 'has a unique body per parliament period' do
    period_a = ParliamentPeriod.make!
    period_b = ParliamentPeriod.make!
    promise  = Promise.make!(body: 'body', parliament_period: period_a)

    Promise.make(body: promise.body, parliament_period: period_a).should_not be_valid
    Promise.make(body: promise.body, parliament_period: period_b).should be_valid
  end

  it 'has a unique external id' do
    invalid = Promise.make
    invalid.external_id = promise.external_id

    invalid.should_not be_valid
  end

  it 'has party names' do
    parties = [Party.make!(name: 'A'), Party.make!(name: 'B')]
    promise = Promise.make!(promisor: Government.make!(parties: parties))

    promise.parties.should == parties
    promise.party_names.should == %w[A B]
  end

  it 'can set a promisor party'
  it 'can set a promisor government'

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
    promise.promise_connections.create! issue: Issue.make!, status: 'related'
    promise.issues.size.should == 1
  end

  it "won't add the same issue twice" do
    issue = Issue.make!

    promise.promise_connections.create! issue: issue, status: 'related'

    expect {
      promise.promise_connections.create! issue: issue, status: 'related'
    }.to raise_error(ActiveRecord::RecordInvalid)

    promise.issues.size.should == 1
  end

  it 'has a list of parliament periods' do
    Promise.parliament_periods.should == []
    Promise.make!(parliament_period: ParliamentPeriod.make!)
    Promise.parliament_periods.size.should == 1

    Promise.make!(parliament_period: ParliamentPeriod.make!)
    Promise.parliament_periods.size.should == 2
  end

  it 'has a main category' do
    main = Category.make!(main: true)
    child = Category.make!(main: false)
    main.children << child

    with_main = Promise.make!(categories: [main])
    without_main = Promise.make!(categories: [child])

    with_main.main_category.should == main
    without_main.main_category.should == main
  end
end