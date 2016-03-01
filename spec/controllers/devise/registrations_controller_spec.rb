require 'spec_helper'

describe Devise::RegistrationsController do
  let(:representative) { Representative.make! :confirmed, password: '111111', password_confirmation: '111111' }

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:representative]
    sign_in representative
  end

  it "allows a representative to change her password" do
    put :update, representative: { current_password:      '111111',
                                   password:              '222222',
                                   password_confirmation: '222222'}
    representative.reload.valid_password?('222222').should be true
  end

  it "requires that the current_password is set" do
    put :update, representative: { password:              '222222',
                                   password_confirmation: '222222'}
    representative.reload.valid_password?('222222').should be false
  end

  it "requires that the new password is confirmed" do
    put :update, representative: { current_password:      '111111',
                                   password:              '222222',
                                   password_confirmation: '3'}
    representative.reload.valid_password?('111111').should be true
  end

end
