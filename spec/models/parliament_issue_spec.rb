require 'spec_helper'

describe ParliamentIssue do
  it 'humanizes the status string' do
    ParliamentIssue.make!(:status => 'ikke_behandlet').status_text.should == 'Ikke behandlet'
  end

  it 'knows if the issue was processed' do
    ParliamentIssue.make!(:status => "behandlet").should be_processed
  end
end
