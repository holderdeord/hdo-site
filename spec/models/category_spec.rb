require 'spec_helper'

describe Category do
  it "should have unique names" do
  	valid = Category.create!(:name => "foo")
  	invalid = Category.create(:name => "foo")

  	invalid.should_not be_valid
  end
end
