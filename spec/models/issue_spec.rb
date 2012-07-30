require 'spec_helper'

describe Issue do
  it 'humanizes the status string' do
    Issue.make!(:status => 'ikke_behandlet').status_text.should == 'Ikke behandlet'
  end
  
  it 'knows if the issue was processed' do
    Issue.make!(:status => "behandlet").should be_processed
  end
end
