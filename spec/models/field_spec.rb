require 'spec_helper'

describe Field do
  it "can create a topic" do
    f = Field.create!(:name => "Education")
    f.topics.create(:title => "Scores")
    
    f.topics.first.title.should == "Scores"
  end
end
