require 'spec_helper'

describe HomeController do
  it 'disallows robots in non-production environments' do
    get :robots

    body = response.body
    body.should include("User-Agent: *")
    body.should include("Disallow: /")
  end

  context 'with rendered views' do
    render_views

    it 'renders home#index' do
      get :index

      response.should have_rendered(:index)
    end
  end

  context 'blog' do
    it 'shows only the newest blog post'
    it 'shows links to the last three posts'
  end
end
