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
    @admin_party_comment = PartyComment.find_by_issue_id_and_id(parmas[:issue_id], params[:id])

    respond_to do |format|
      if @admin_party_comment.update_attributes(params[:admin_party_comment])
        format.html { redirect_to @admin_party_comment, notice: 'Party comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @admin_party_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/issue/1/party_comments/1
  # DELETE /admin/issue/1/party_comments/1.json
  def destroy
    @admin_party_comment = PartyComment.find_by_issue_id_and_id(params[:issue_id], params[:id])
    @admin_party_comment.destroy

    respond_to do |format|
      format.html { redirect_to admin_party_comments_url }
      format.json { head :no_content }
    end
  end
end
