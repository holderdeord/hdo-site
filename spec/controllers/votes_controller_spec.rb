require 'spec_helper'

describe VotesController do
  render_views
  
  it "should set the votes variable on index" do
    get :index

    assigns(:votes).should_not be_nil
  end

  it "should return the vote on get" do
    @vote = Vote.make!

    get :show, :id => @vote

    assigns(:vote).should eq @vote
  end

  it "should be not be paginated when accessing votes#all" do
    40.times { Vote.make! }

    get :all

    Nokogiri::HTML.parse(response.body).inner_text.strip.should =~ /Viser alle/
  end
end
