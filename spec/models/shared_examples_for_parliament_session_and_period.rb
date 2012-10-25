require 'spec_helper'

shared_examples 'parliament session and period' do
  it 'knows the current period' do
    obj = described_class.make! start_date: 1.month.ago, end_date: 1.month.from_now
    described_class.current.should == obj
  end

  it 'finds the instance at a given date' do
    obj = described_class.make! start_date: 2.months.ago, end_date: 1.month.ago
    described_class.for_date(40.days.ago)
  end
end