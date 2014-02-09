# encoding: utf-8

require 'spec_helper'

describe PromiseConnection do
  before do
    ParliamentPeriod.stub(current: double(start_date: 1.month.ago.to_date))
  end

  it 'should have a valid blueprint' do
    PromiseConnection.make.should be_valid
  end

  it 'should be invalid without a promise' do
    PromiseConnection.make(promise: nil).should be_invalid
  end

  it 'should be invalid without a issue' do
    PromiseConnection.make(issue: nil).should be_invalid
  end

  it 'validates the status values' do
    pc = PromiseConnection.make

    pc.status = 'kept'
    pc.should be_valid

    pc.status = 'partially_kept'
    pc.should be_valid

    pc.status = 'broken'
    pc.should be_valid

    pc.status = 'related'
    pc.should be_valid

    pc.status = 'unrelated'
    pc.should_not be_valid
  end

  it 'has a translation for the status' do
    pc = PromiseConnection.make

    I18n.with_locale :nb do
      pc.status = 'kept'
      pc.status_text.should == 'holdt'

      pc.status = 'partially_kept'
      pc.status_text.should == 'delvis holdt'

      pc.status = 'related'
      pc.status_text.should == 'relatert'

      pc.status = 'unrelated'
      expect { pc.status_text }.to raise_error
    end
  end

  it 'disallows promises from the next period' do
    current_period = ParliamentPeriod.make!(start_date: 1.year.ago, end_date: 1.day.from_now)
    next_period    = ParliamentPeriod.make!(start_date: 2.days.from_now, end_date: 1.year.from_now)

    current_promise = Promise.make!(parliament_period: current_period)
    next_promise = Promise.make!(parliament_period: next_period)

    PromiseConnection.make(status: 'kept', promise: current_promise).should be_valid
    PromiseConnection.make(status: 'broken', promise: next_promise).should_not be_valid
  end

  it 'allows related promises from the next period' do
    current_period = ParliamentPeriod.make!(start_date: 1.year.ago, end_date: 1.day.from_now)
    next_period    = ParliamentPeriod.make!(start_date: 2.days.from_now, end_date: 1.year.from_now)
    next_promise   = Promise.make!(parliament_period: next_period)

    PromiseConnection.make(promise: next_promise, status: 'related').should be_valid
  end

end
