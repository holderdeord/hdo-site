require 'spec_helper'

describe Vote do
	it "should have a valid blueprint" do
		v = Vote.make
		v.should be_valid
	end
	it "should be invalid with no issues" do
		v = Vote.make( :issues => [])
		v.should_not be_valid
	end
	it "should be invalid without a time" do
		v = Vote.make(:time => nil)
		v.should_not be_valid
	end
end
