require 'spec_helper'

describe ConfirmationsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:representative]
  end

  context "with unconfirmed representative" do
    let(:rep) { Representative.make! :with_email}
    before(:each) do
      rep.send_confirmation_instructions
      rep.confirmation_token = "real confirmation token"
      rep.save!
    end

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

    it "confirms the representative if a password is set" do
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
end
