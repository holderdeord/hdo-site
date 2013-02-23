require 'spec_helper'

describe HomeController do
  context 'issues' do
    it 'loads only published issues' do
      shown     = Issue.make! status: 'published'
      not_shown = Issue.make! status: 'shelved'

      get :index

      assigns(:issues).should == [shown]
    end
  end

  context 'with rendered views' do
    render_views

    it 'renders home#index' do
      get :index

      response.should have_rendered(:index)
    end
  end
end