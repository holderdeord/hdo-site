require 'spec_helper'

describe DocsController do
  it 'renders docs#index' do
    get :index
    response.should have_rendered(:index)
  end

  it 'renders docs#analysis' do
    sign_in User.make!

    get :analysis
    response.should have_rendered(:analysis)
  end
end
