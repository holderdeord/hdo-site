require 'spec_helper'

describe Issue, :search do
  it 'finds "formueskatten" for query "skatt"' do
    issue = Issue.make!(title: "fjerne formueskatten", status: 'published')
    refresh_index

    results = Issue.search('skatt').results
    results.should_not be_empty
    results.first.load.should == issue
  end
end