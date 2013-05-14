require 'spec_helper'

describe SearchController do
  let(:searcher) { mock(Hdo::Search::Searcher) }
  let(:search_response) { mock(Hdo::Search::Searcher::Response, :success? => true, results: []) }
  let(:issue_result) { mock(type: 'issue')  }

  it 'can search for #all' do
    Hdo::Search::Searcher.should_receive(:new).with("skatt").and_return(searcher)

    search_response.stub(:results => [issue_result])
    searcher.should_receive(:all).and_return search_response

    get :all, query: "skatt"
    response.should be_success

    assigns(:results).should == [['issue', [issue_result]]]
  end

  it 'can search for #autocomplete' do
    Hdo::Search::Searcher.should_receive(:new).with("skatt").and_return(searcher)
    searcher.should_receive(:autocomplete).and_return search_response

    get :autocomplete, query: 'skatt', format: :json
    response.should be_success
  end

  context 'with real search', search: true do
    let(:described_class) { Issue }

    it 'provides urls consistent with Issue#to_param' do
      issue = Issue.make!(title: "Fjerne formueskatten", status: 'published')
      refresh_index

      get :autocomplete, query: 'skatt', format: :json
      response.should be_success

      hits = JSON.parse(response.body)['issue']
      hits.size.should == 1

      issue_result = hits.first
      URI.parse(issue_result['url']).path.should == "/issues/#{issue.to_param}"
    end
  end

end
