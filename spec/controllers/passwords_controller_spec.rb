require 'spec_helper'

describe PasswordsController do
  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context "hdo user" do

    let(:user) { User.make!(email: 'user@example.com', password: '654321', password_confirmation: '654321') }

    context "with views" do
      render_views
      it "shows the forgot password page" do
        @request.path = new_user_password_path
        get :new
        response.should have_rendered(:new)
      end
    end

    it "sends an existing user a reset email" do
      @request.path = user_password_path

      User.should_receive(:send_reset_password_instructions).with({ 'email' => user.email }).and_return(user)

      put :create, user: { email: user.email }
    end

    it "sets a reset token on the user" do
      User.send_reset_password_instructions({email: user.email})
      user.reload.reset_password_token.should_not be_nil
    end

    it "lets a user set a new password" do
      User.send_reset_password_instructions({email: user.email})
      @request.path = user_password_path

      put :update, user: {
        reset_password_token:  user.reload.reset_password_token,
        password:              '111111',
        password_confirmation: '111111'
      }

      user.reload.valid_password?('111111').should be true
    end

    it "only sets the password if the confirmation matches" do
      User.send_reset_password_instructions({email: user.email})
      @request.path = user_password_path

      put :update, user: {
        reset_password_token:  user.reload.reset_password_token,
        password:              '111111',
        password_confirmation: '222222'
      }

      user.reload.valid_password?('111111').should be false
    end
  end

  context "representative" do
    let(:rep) { Representative.make! :confirmed, password: '123456', password_confirmation: '123456' }

    it "sends an e-mail" do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      Representative.should_receive(:send_reset_password_instructions).with({ 'email' => rep.email }).and_return(rep)

      put :create, user: { email: rep.email }
    end

    it "sets a reset token" do
      put :create, user: { email: rep.email }
      rep.reload.reset_password_token.should_not be_nil
    end

    it "changes the password" do
      @request.env["devise.mapping"] = Devise.mappings[:representative]
      Representative.send_reset_password_instructions({email: rep.email})

      put :update, representative: {
        reset_password_token:  rep.reload.reset_password_token,
        password:              '111111',
        password_confirmation: '111111'
      }

      rep.reload.valid_password?('111111').should be true
    end

    it "validates password confirmation" do
      @request.env["devise.mapping"] = Devise.mappings[:representative]
      Representative.send_reset_password_instructions({email: rep.email})

      put :update, representative: {
        reset_password_token:  rep.reload.reset_password_token,
        password:              '111111',
        password_confirmation: '2222222'
      }

      rep.reload.valid_password?('111111').should be false
    end
  end

end
