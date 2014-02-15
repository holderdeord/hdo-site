class PromisesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    create_search

    respond_to do |format|
      format.html
      format.json { render json: @search.as_json }
    end
  end

  def show
    @promise  = Promise.find(params[:id])

    params.merge!(
      :parliament_period => @promise.parliament_period_name,
      :category => @promise.main_category.human_name,
      :promisor => @promise.promisor_name
    )

    create_search
    render :index
  end

  private

  def create_search
    @search = Hdo::Search::Promises.new(params, view_context)
    @search.size = params[:size].to_i if params[:size] && request.xhr?
  end
end
