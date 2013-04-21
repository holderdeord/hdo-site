require 'spec_helper'
require 'models/shared_examples_for_parliament_session_and_period'

describe ParliamentPeriod do
  it_behaves_like 'parliament session and period'

  it 'can find by name' do
    period = ParliamentPeriod.create!(start_date: '2009-10-01', end_date: '2010-09-30')
    ParliamentPeriod.named('2009-2010').should == period
  end
end
