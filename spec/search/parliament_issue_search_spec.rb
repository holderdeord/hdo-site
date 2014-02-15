require 'spec_helper'

describe ParliamentIssue, :search do
  it 'indexes non-attribute data (no partial update)' do
    ParliamentSession.make!(start_date: 1.month.ago, end_date: 1.month.from_now)
    pi = ParliamentIssue.make!(status: 'motatt', last_update: 1.day.ago)

    refresh_index
    ParliamentIssue.search('*').results.first.status_name.should == 'Motatt'

    pi.update_attributes!(status: 'behandlet')

    refresh_index
    ParliamentIssue.search('*').results.first.status_name.should == 'Behandlet'
  end

end