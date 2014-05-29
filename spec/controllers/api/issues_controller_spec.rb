require 'spec_helper'

describe Api::IssuesController do
  it 'can GET :index' do
    get :index, format: :hal
    response.should be_success
  end

  it 'can GET :show for a published issue' do
    i = Issue.make!(status: 'published')
    get :show, id: i, format: :hal

    response.should be_success
  end

  it 'returns 404 for a non-published issue' do
    i = Issue.make!
    get :show, id: i, format: :hal

    response.should be_not_found
  end
end
