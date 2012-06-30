require 'spec_helper'

describe Topic do
  it "can create a new topic" do
    t = Topic.create!(:title => "foo", :description => "bar")
    t.title.should == "foo"
    t.description.should == "bar"
  end
  
  it "is invalid without a title" do
    t = Topic.create(:description => "foo")
    t.should_not be_valid
  end
  
  it "can have multiple categories" do
    a = Category.create!(:name => "Skole")
    b = Category.create!(:name => "Forsvar")
    
    
    t = Topic.create!(:title => "foo")
    t.categories << a
    t.categories << b
    
    t.categories.map(&:name).should == ["Skole", "Forsvar"]
  end
end
