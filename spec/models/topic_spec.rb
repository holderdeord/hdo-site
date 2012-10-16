# encoding: UTF-8
require 'spec_helper'

describe Topic do
  it "can add issues" do
    f = Topic.create!(:name => "Education")
    f.issues.create(:title => "Scores")

    f.issues.first.title.should == "Scores"
  end

  it 'can add issues' do
    t = Topic.make!

    t.issues << Issue.make!
    t.issues.size.should == 1
  end

  it "won't add the same issue twice" do
    t = Topic.make!
    i = Issue.make!

    t.issues << i
    t.issues << i

    t.issues.size.should == 1
  end

  it 'has creates column groups' do
    f1 = Topic.make!
    Topic.column_groups.should == [[f1]]

    f2 = Topic.make!
    Topic.column_groups.should == [[f1, f2]]

    f3 = Topic.make!
    Topic.column_groups.should == [[f1], [f2], [f3]]

    f4 = Topic.make!
    Topic.column_groups.should == [[f1], [f2], [f3], [f4]]
  end

  it 'has a downcased name' do
    Topic.make!(:name => "Foo").downcased_name.should == 'foo'
  end

  it 'has a downcased name for non-ASCII titles' do
    Topic.make!(:name => "ÆÅØ").downcased_name.should == 'æåø'
  end
end
