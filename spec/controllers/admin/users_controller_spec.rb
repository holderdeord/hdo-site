require 'spec_helper'

describe Admin::UsersController do
  context 'admin' do
    let(:user)    { User.make! }
    before(:each) { sign_in User.make!(role: 'admin') }

    it 'can show index' do
      get :index

      assigns(:users).should be_kind_of(Array)
    end

    it 'can show a user' do
      get :show, id: user

      assigns(:user).should == user
      response.should have_rendered(:show)
    end

    it 'can not create a new user' do
      get :new

      response.should redirect_to admin_users_path
      flash.alert.should_not be_empty
    end

    it 'can not edit a user' do
      get :edit, id: user

      response.should redirect_to admin_users_path
      flash.alert.should_not be_blank
    end

    it 'can not update a user' do
      put :update, id: user, user: { email: 'hello@example.com' }

      response.should redirect_to admin_users_path
      flash.alert.should_not be_blank
    end

    it 'can not destroy a user' do
      delete :destroy, id: user

      response.should redirect_to admin_users_path
      flash.alert.should_not be_blank
    end
  end

  context 'superadmin' do
    let(:user)    { User.make! }
    before(:each) { sign_in User.make!(role: 'superadmin') }

    it 'can create a new user' do
      get :new

      assigns(:user).should be_kind_of(User)

      response.should be_success
      response.should have_rendered(:new)
    end

    it 'can edit a user' do
      get :edit, id: user

      assigns(:user).should == user
      response.should have_rendered(:edit)
    end

    it 'can update a user' do
      put :update, id: user, user: { email: 'hello@example.com' }

      assigns(:user).should == user.reload
      user.email.should == 'hello@example.com'

      response.should redirect_to admin_user_path(user)
    end

    it 'can destroy a user' do
      delete :destroy, id: user

      response.should redirect_to admin_users_path
      flash.alert.should be_blank
    end
  end
end
