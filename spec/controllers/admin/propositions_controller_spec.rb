require 'spec_helper'

describe Admin::PropositionsController do
  before(:suite) { Proposition.create_index! }
  before { sign_in User.make! }
  before { ParliamentSession.make!(start_date: 1.month.ago, end_date: 1.month.from_now) }

  it 'should get :index' do
    get :index

    response.should be_ok
    response.should have_rendered :index
  end

  it 'should get :edit' do
    prop = Proposition.make!(:with_vote)
    prop.run_callbacks(:commit) # for indexing

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
    response.should redirect_to(edit_admin_proposition_path(prop))

    prop.reload.simple_description.should == "foo"
  end

  it 'should treats empty string as nil' do
    prop = Proposition.make!(:with_vote)
    prop.simple_description.should be_nil
    prop.simple_body.should be_nil

    attrs = {simple_description: "", simple_body: "", issues: []}

    post :update, id: prop, save: '', proposition: attrs
    response.should redirect_to(edit_admin_proposition_path(prop))

    prop.reload

    prop.simple_description.should be_nil
    prop.simple_body.should be_nil
  end

  it 'should post :update and publish' do
    prop = Proposition.make!(:with_vote)
    prop.should be_pending

    post :update, id: prop, save_publish: '', proposition: {simple_description: 'foo'}
    response.should redirect_to(admin_propositions_path(status: 'published'))

    prop.reload.should be_published
  end

  it 'should post :update and publish and redirect to the next proposition' do
    props = [Proposition.make!(:with_vote), Proposition.make!(:with_vote)]
    props.first.should be_pending

    post :update, id: props.first, save_publish_next: '', proposition: {simple_description: 'foo'}
    response.should redirect_to(edit_admin_proposition_path(props.last))

    props.first.reload.should be_published
  end

  it 'should update issues' do
    issue = Issue.make!(proposition_connections: [])
    prop = Proposition.make!(:with_vote)

    issue.proposition_connections.should be_empty

    post :update, id: prop, save: '', proposition: {issues: ["", issue.id]}
    response.should redirect_to(edit_admin_proposition_path(prop))

    pc = issue.reload.proposition_connections.first
    pc.should_not be_nil
    pc.proposition.should == prop
  end
end
