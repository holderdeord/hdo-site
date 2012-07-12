require 'spec_helper'

describe Committee do
  it "should have unique names" do
    c = Committee.create!(:name => 'committee')
    c2 = Committee.create(:name => 'committee')

    c2.should_not be_valid
  end
end
