# encoding: UTF-8
require 'spec_helper'

describe Field do
  it "can create a topic" do
    f = Field.create!(:name => "Education")
    f.topics.create(:title => "Scores")

    f.topics.first.title.should == "Scores"
  end

  it 'has creates column groups' do
    f1 = Field.make!
    Field.column_groups.should == [[f1]]

    f2 = Field.make!
    Field.column_groups.should == [[f1, f2]]

    f3 = Field.make!
    Field.column_groups.should == [[f1], [f2], [f3]]

    f4 = Field.make!
    Field.column_groups.should == [[f1], [f2], [f3], [f4]]
  end

  it 'has a downcased name' do
    Field.make!(:name => "Foo").downcased_name.should == 'foo'
  end

  it 'has a downcased name for non-ASCII titles' do
    Field.make!(:name => "ÆÅØ").downcased_name.should == 'æåø'
  end
end
