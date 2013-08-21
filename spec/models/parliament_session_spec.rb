require 'spec_helper'
require 'models/shared_examples_for_parliament_session_and_period'

describe ParliamentSession do
  it_behaves_like 'parliament session and period'

  it 'finds votes within the time range' do
    start_date = 1.year.ago
    end_date = 6.months.ago

    hit = Vote.make!(time: 10.months.ago)
    miss = Vote.make!(time: 13.months.ago)

    obj = described_class.make! start_date: start_date, end_date: end_date
    obj.votes.to_a.should == [hit]
  end

end
