# TODO: (Jonathan 2013-3-10) This code is not presently in use. I leave it here to perhaps be adopted when we make an API to be used by widgets etc.

class Admin::PartyCommentsController < AdminController
  # GET /admin/issue/1/party_comments
  # GET /admin/issue/1/party_comments.json
  def index
    @admin_party_comments = PartyComment.find_all_by_issue_id(params[:issue_id])

    render json: @admin_party_comments
  end

  # POST /admin/issue/1/party_comments
  # POST /admin/issue/1/party_comments.json
  def create
    @admin_party_comment = PartyComment.create!(params[:admin_party_comment].merge({ issue_id: params[:issue_id]}))

    render json: @admin_party_comment
  end

  # PUT /admin/issue/1/party_comments/1
  # PUT /admin/issue/1/party_comments/1.json
  def update
    @admin_party_comment = PartyComment.find_by_issue_id_and_id(params[:issue_id], params[:id])
    @admin_party_comment.update_attributes(params[:admin_party_comment])

    if @admin_party_comment.save
      render json: @admin_party_comment
    else
      head :bad_request
    end
  end

  # DELETE /admin/issue/1/party_comments/1
  # DELETE /admin/issue/1/party_comments/1.json
  def destroy
    @admin_party_comment = PartyComment.find_by_issue_id_and_id(params[:issue_id], params[:id])
    @admin_party_comment.destroy

    head :ok
  end
end
