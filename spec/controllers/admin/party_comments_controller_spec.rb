require 'spec_helper'

describe Admin::PartyCommentsController do

  before(:each) { sign_in User.make!(role: 'admin') }
  let(:party_comment) { PartyComment.make! }

  describe "GET index" do
    it "assigns all admin_party_comments as @admin_party_comments" do
      party_comment = PartyComment.make!
      get :index, { id: party_comment.id, issue_id: party_comment.issue.id }
      response.should be_ok
      assigns(:admin_party_comments).should eq([party_comment])
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:issue) { Issue.make! }
      let(:party) { Party.make! }

      it "creates a new PartyComment" do
        valid_attributes = {
          issue_id: issue.id,
          party_id: party.id,
          title:    'haha',
          body:     'not..'
        }
        expect {
          post :create, { issue_id: issue.id, admin_party_comment: valid_attributes }
        }.to change(PartyComment, :count).by(1)
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested admin_party_comment" do
        party_comment = PartyComment.make!
        PartyComment.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:issue_id => party_comment.issue_id,:id => party_comment.to_param, :admin_party_comment => { "these" => "params" }}
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested admin_party_comment" do
      party_comment = PartyComment.make!
      expect {
        delete :destroy, { issue_id: party_comment.issue.id, id: party_comment.to_param }
      }.to change(PartyComment, :count).by(-1)
    end
  end

end
