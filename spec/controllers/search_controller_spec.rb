require 'spec_helper'

describe SearchController do
  let(:searcher) { double(Hdo::Search::Searcher) }
  let(:search_response) { double(Hdo::Search::Searcher::Response, :success? => true, results: []) }
  let(:issue_result) { double(_type: 'issue')  }

  it 'can search for #all' do
    Hdo::Search::Searcher.should_receive(:new).with("skatt", nil).and_return(searcher)

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

end
