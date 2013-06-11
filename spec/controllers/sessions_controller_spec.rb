require 'spec_helper'

describe SessionsController do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  it "Signs in a user" do
    User.make!(email: 'user@example.com', password: '654321', password_confirmation: '654321')

    post :create, user: { email: 'user@example.com', password: '654321' }

    response.should redirect_to admin_root_path
  end

  it "signs in a representatie" do
    Representative.make!(:attending, email: 'representative@example.com', password: '123456', password_confirmation: '123456')

    post :create, user: { email: 'representative@example.com', password: '123456' }

    response.should redirect_to representative_root_path
  end

  it "doesn't sign in some random dude" do
    post :create, user: { email: 'random@haker.com', password: '13377331' }

    response.should_not redirect_to admin_root_path
  end
end
