require 'spec_helper'

describe SearchController do
  let(:searcher) { mock(Hdo::Search::Searcher) }
  let(:response) { mock(Hdo::Search::Searcher::Response, :success? => true, :results => []) }
  let(:issue_result) { mock(type: 'issue')  }

  it 'can search for #all' do
    Hdo::Search::Searcher.should_receive(:new).with("skatt").and_return(searcher)

    searcher.should_receive(:all).and_return response
    response.stub(:results => [issue_result])

    get :all, query: "skatt"

    assigns(:results).should == [['issue', [issue_result]]]
  end

  it 'can search for #autocomplete' do
    Hdo::Search::Searcher.should_receive(:new).with("skatt").and_return(searcher)
    searcher.should_receive(:autocomplete).and_return response

    get :autocomplete, query: 'skatt'
  end
end
