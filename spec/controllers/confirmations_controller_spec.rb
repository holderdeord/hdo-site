require 'spec_helper'

describe ConfirmationsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:representative]
  end

  let(:rep) { Representative.make! :with_email}
  before(:each) do
    rep.send_confirmation_instructions
    rep.confirmation_token = "real confirmation token"
    rep.save!
  end

  context "with unconfirmed representative" do

    it "finds no representative for a non-existant token" do
      get :show, {confirmation_token: 'not a real one'}
      assigns(:confirmable).should be_new_record
    end

    it "finds the representative by the confirmation token" do
      get :show, { confirmation_token: rep.confirmation_token }
      assigns(:confirmable).should eq rep
    end

    it "does not confirm the rep without setting a password" do
      put :update, { confirmation_token: rep.confirmation_token }
      rep.reload
      rep.should_not be_confirmed
    end

    it "confirms the representative if a password is being set" do
      put :update, { confirmation_token: rep.confirmation_token,
        representative: {
          password: '123456',
          password_confirmation: '123456'
        }
      }
      rep.reload
      rep.should be_confirmed
    end

  end

  context "unconfirmed representative with password" do
    before(:each) do
      rep.update_attributes!(password: '123456', password_confirmation: '123456')
    end

    it "confirms a representative that's already got a password" do
      get :show, { confirmation_token: rep.confirmation_token }
      rep.reload
      rep.should be_confirmed
    end

    it "doesn't let a password be overridden" do
      put :update, { confirmation_token: rep.confirmation_token,
        representative: {
          password: '654321',
          password_confirmation: '654321'
        }
      }
      rep.reload
      rep.should_not be_confirmed
      assigns(:confirmable).errors.should_not be_empty
    end
  end

  it "redirects to login for a non-existant confirmation token" do
    get :show, confirmation_token: 'a'
    response.should redirect_to new_user_session_path
  end
end
