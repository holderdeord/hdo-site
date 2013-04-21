require 'spec_helper'

describe Admin::RepresentativesController do
  let(:representative) { Representative.make! }

  context 'not logged in' do
    it 'should not be able to access the controller' do
      get :edit, id: representative.to_param
      response.should redirect_to(new_user_session_path)
    end
  end

  context 'logged in' do
    before(:each) { sign_in User.make!(role: 'superadmin') }

    it "can update twitter_id and email" do
      put :update, id: representative.to_param, representative: { twitter_id: 'foo' }

      response.should redirect_to(admin_representatives_path)
      representative.reload.twitter_id.should == 'foo'
    end

    it "sets twitter_id to nil if blank" do
      put :update, id: representative.to_param, representative: { twitter_id: '' }

      response.should redirect_to(admin_representatives_path)
      representative.reload.twitter_id.should be_nil
    end

    it 'will not overwrite imported attributes' do
      first_name = representative.first_name
      last_name  = representative.last_name

      put :update, id: representative.to_param, representative: { first_name: 'Foo', last_name: 'Bar' }

      response.should redirect_to(admin_representatives_path)
      representative.reload

      representative.first_name.should == first_name
      representative.last_name.should == last_name
    end

    it "should activate the representative" do
      rep = Representative.make!(email: 'e@ma.il')

      get :activate, representative_id: rep.to_param
      response.should redirect_to admin_representatives_path
      rep.reload.confirmation_sent_at.should_not be_nil
    end

    it "should not attempt to activate a representative with no email" do
      rep = Representative.make!

      get :activate, representative_id: rep.to_param
      response.should redirect_to admin_representatives_path
      flash.should_not be_nil
      rep.reload.confirmation_sent_at.should be_nil
    end

    it "should reset the representative's password" do
      rep = Representative.make! :confirmed

      get :reset_password, representative_id: rep.to_param
      response.should redirect_to admin_representatives_path
      rep.reload.reset_password_sent_at.should_not be_nil
    end

    it "should not attempt to reset a representative's password with no email" do
      rep = Representative.make!(:confirmed, email: nil)

      get :reset_password, representative_id: rep.to_param
      response.should redirect_to admin_representatives_path
      rep.reload.reset_password_sent_at.should be_nil
    end
  end
end
