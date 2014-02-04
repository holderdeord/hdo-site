require 'spec_helper'

describe PropositionsController do
  it 'can GET :index' do
    get :index

    response.should be_ok
    response.should have_rendered(:index)
  end

  it 'can GET :show' do
    proposition = Proposition.make!

    get :show, id: proposition

    response.should be_ok
    response.should have_rendered(:show)
  end
end
