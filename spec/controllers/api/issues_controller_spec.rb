require 'spec_helper'

describe Api::IssuesController, :api do
  it 'can GET :index' do
    Issue.make!(status: 'published')
    Issue.make!(status: 'in_progress')

    get :index, format: :hal

    response.should be_success
    json_response['total'].should == 1
    relations.should == %w[find issues self] # TODO: pagination rels
  end

  it 'can GET :show for a published issue' do
    i = Issue.make!(status: 'published')

    get :show, id: i, format: :hal

    response.should be_success
    relations.should == %w[promises self]
  end

  it 'returns 404 for a non-published issue' do
    i = Issue.make!

    get :show, id: i, format: :hal
    response.should be_not_found
  end
end
