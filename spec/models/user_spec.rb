require 'spec_helper'

describe User do
  it "should be valid if passwords match" do
    u = User.make!

    u.should be_valid
  end
end
