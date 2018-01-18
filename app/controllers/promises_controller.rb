class PromisesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    create_search

    respond_to do |format|
      format.html { redirect_to 'https://lofter.holderdeord.no/', status: 302 }
      format.json { render json: @search.as_json }
      format.csv  { send_data @search.as_csv }
      format.tsv  { send_data @search.as_csv(col_sep: "\t") }
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
    @search.size = params[:size].to_i if params[:size]
  end
end
