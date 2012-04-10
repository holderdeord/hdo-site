class PromisesController < ApplicationController
  def index
    @promises = Promise.all

    respond_to do |format|
      format.html
      format.json { render json: @promises }
      format.xml  { render xml:  @promises }
    end
  end

  def show
    @promise = Promise.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @promise }
      format.xml  { render xml:  @promise }
    end
  end

  def new
    @promise = Promise.new

    respond_to do |format|
      format.html
      format.json { render json: @promise }
      format.xml  { render xml:  @promise}
    end
  end

  def edit
    @promise = Promise.find(params[:id])
  end

  def create
    @promise = Promise.new(params[:promise])

    respond_to do |format|
      if @promise.save
        format.html { redirect_to @promise, notice: I18n.t('app.created.promise') }
        format.json { render json: @promise, status: :created, location: @promise }
        format.xml  { render xml:  @xml,     status: :created, location: @promise }
      else
        format.html { render action: "new" }
        format.json { render json: @promise.errors, status: :unprocessable_entity }
        format.xml  { render xml:  @promise.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @promise = Promise.find(params[:id])

    respond_to do |format|
      if @promise.update_attributes(params[:promise])
        format.html { redirect_to @promise, notice: I18n.t('app.updated.promise') }
        format.json { head :no_content }
        format.xml  { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @promise.errors, status: :unprocessable_entity }
        format.xml  { render xml:  @promise.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @promise = Promise.find(params[:id])
    @promise.destroy

    respond_to do |format|
      format.html { redirect_to promises_url }
      format.json { head :no_content }
    end
  end
  
  private
  
end
