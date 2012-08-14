class FieldsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_topics, :only => [:new, :edit]
  before_filter :fetch_field,  :only => [:show, :edit, :update, :destroy]

  # GET /fields
  # GET /fields.json
  def index
    @fields = Field.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @fields }
    end
  end

  # GET /fields/1
  # GET /fields/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @field }
    end
  end

  # GET /fields/new
  # GET /fields/new.json
  def new
    @field = Field.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @field }
    end
  end

  # GET /fields/1/edit
  def edit
  end

  # POST /fields
  # POST /fields.json
  def create
    @field = Field.new(params[:field])

    respond_to do |format|
      if @field.save
        format.html { redirect_to @field, notice: 'Field was successfully created.' }
        format.json { render json: @field, status: :created, location: @field }
      else
        format.html { render action: "new" }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /fields/1
  # PUT /fields/1.json
  def update
    respond_to do |format|
      if @field.update_attributes(params[:field])
        format.html { redirect_to @field, notice: 'Field was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @field.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /fields/1
  # DELETE /fields/1.json
  def destroy
    @field.destroy

    respond_to do |format|
      format.html { redirect_to fields_url }
      format.json { head :no_content }
    end
  end

  private

  def fetch_topics
    @topics = Topic.order :title
  end

  def fetch_field
    @field = Field.find(params[:id])
  end
end
