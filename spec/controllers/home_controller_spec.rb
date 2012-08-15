require 'spec_helper'

describe HomeController do
  context 'with rendered views' do
    render_views

    it 'renders home#index' do
      Topic.make!

      get :index

      response.should have_rendered(:index)
    end
  end
end