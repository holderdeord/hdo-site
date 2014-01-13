require 'spec_helper'

describe Admin::PropositionsController do
  before { sign_in User.make! }
  before { ParliamentSession.make!(start_date: 1.month.ago, end_date: 1.month.from_now) }

  it 'should get :index' do
    get :index
    response.should be_ok
    response.should have_rendered :index
  end

  it 'should get :edit' do
    prop = Proposition.make!(:with_vote)

    get :edit, id: prop
    response.should be_ok
    response.should have_rendered :edit
  end


  it 'should post :update' do
    prop = Proposition.make!(:with_vote)
    prop.simple_description.should be_nil
    prop.simple_body.should be_nil

    attrs = {simple_description: "foo", simple_body: "bar", issues: []}

    post :update, id: prop, save: '', proposition: attrs
    response.should be_ok
    response.should have_rendered :edit

    prop.reload.simple_description.should == "foo"
  end

  it 'should treats empty string as nil' do
    prop = Proposition.make!(:with_vote)
    prop.simple_description.should be_nil
    prop.simple_body.should be_nil

    attrs = {simple_description: "", simple_body: "", issues: []}

    post :update, id: prop, save: '', proposition: attrs
    response.should be_ok

    prop.reload

    prop.simple_description.should be_nil
    prop.simple_body.should be_nil
  end

  it 'should post :update and publish' do
    prop = Proposition.make!(:with_vote)
    prop.should be_pending

    post :update, id: prop, save_publish: '', proposition: {}
    response.should redirect_to(admin_propositions_path(status: 'published'))

    prop.reload.should be_published
  end

  it 'should post :update and publish and redirect to the next proposition' do
    props = [Proposition.make!, Proposition.make!(:with_vote)]
    props.last.should be_pending

    post :update, id: props.last, save_publish_next: '', proposition: {}
    response.should redirect_to(edit_admin_proposition_path(props.first))

    props.last.reload.should be_published
  end

  it 'should update issues' do
    issue = Issue.make!(proposition_connections: [])
    prop = Proposition.make!(:with_vote)

    issue.proposition_connections.should be_empty

    post :update, id: prop, save: '', proposition: {issues: ["", issue.id]}
    response.should be_ok

    pc = issue.reload.proposition_connections.first
    pc.should_not be_nil
    pc.proposition.should == prop
  end
end
