require 'spec_helper'

describe Admin::RepresentativesController do

  let(:representative) {
    Representative.make!(:id => 1)
  }

  context 'not logged in' do
    it 'should not be able to access the controller' do
      get :index
      response.should redirect_to(new_user_session_path)
    end
  end

  context 'logged in' do
    before(:each) { sign_in User.make! }

    it "can show index" do
      get :index

      response.should be_success
      assigns(:reps_grouped).should be_kind_of(Hash)
    end

    it "can update twitter_id" do
      put :update, id: representative.to_param, representative: { twitter_id: 'foo' }

      response.should be_success
      representative.reload.twitter_id.should == 'foo'
    end

    it "sets twitter_id to nil if blank" do
      put :update, id: representative.to_param, representative: { twitter_id: '' }

      response.should be_success
      representative.reload.twitter_id.should be_nil
    end
  end
end
