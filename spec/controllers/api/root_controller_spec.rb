require 'spec_helper'

describe Api::RootController do
  it 'can get the root' do
    get :index, format: hal
    response.should be_success
  end
end
