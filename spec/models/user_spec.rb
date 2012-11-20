require 'spec_helper'

describe User do
  it "should be valid if passwords match" do
    u = User.make!

    u.should be_valid
  end

  it 'is invalid without a role' do
    u = User.make role: nil
    u.should_not be_valid
  end

  it 'defaults to the admin role' do
    u = User.make
    u.role.should == 'admin'
    u.should be_admin
  end

  it 'can set the superadmin role' do
    u = User.make role: 'superadmin'
    u.should be_valid
    u.should be_superadmin
  end

  it 'is invalid with unknown roles' do
    u = User.make role: 'foo'
    u.should_not be_valid
  end


end
