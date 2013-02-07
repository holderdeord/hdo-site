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
    before(:each) { sign_in User.make! }

    it "can update twitter_id and email" do
      put :update, id: representative.to_param, representative: { twitter_id: 'foo' }

      response.should redirect_to(representative_path(representative))
      representative.reload.twitter_id.should == 'foo'
    end

    it "sets twitter_id to nil if blank" do
      put :update, id: representative.to_param, representative: { twitter_id: '' }

      response.should redirect_to(representative_path(representative))
      representative.reload.twitter_id.should be_nil
    end

    it 'will not overwrite imported attributes' do
      first_name = representative.first_name
      last_name  = representative.last_name

      put :update, id: representative.to_param, representative: { first_name: 'Foo', last_name: 'Bar' }

      response.should redirect_to(representative_path(representative))
      representative.reload

      representative.first_name.should == first_name
      representative.last_name.should == last_name
    end
  end
end
