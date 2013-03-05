class Admin::PartyCommentsController < AdminController
  # GET /admin/issue/1/party_comments
  # GET /admin/issue/1/party_comments.json
  def index
    @admin_party_comments = PartyComment.find_by_issue_id(params[:issue_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @admin_issue/1/party_comments }
    end
  end

  # GET /admin/issue/1/party_comments/1
  # GET /admin/issue/1/party_comments/1.json
  def show
    @admin_party_comment = PartyComment.find_by_issue_id_and_id(params[:issue_id], params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @admin_party_comment }
    end
  end

  # GET /admin/issue/1/party_comments/new
  # GET /admin/issue/1/party_comments/new.json
  def new
    @admin_party_comment = PartyComment.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @admin_party_comment }
    end
  end

  # GET /admin/issue/1/party_comments/1/edit
  def edit
    @admin_party_comment = PartyComment.find(params[:id])
  end

  # POST /admin/issue/1/party_comments
  # POST /admin/issue/1/party_comments.json
  def create
    @admin_party_comment = PartyComment.new(params[:admin_party_comment])

    respond_to do |format|
      if @admin_party_comment.save
        format.html { redirect_to @admin_party_comment, notice: 'Party comment was successfully created.' }
        format.json { render json: @admin_party_comment, status: :created, location: @admin_party_comment }
      else
        format.html { render action: "new" }
        format.json { render json: @admin_party_comment.errors, status: :unprocessable_entity }
      end
    end
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
