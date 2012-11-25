class PartiesController < ApplicationController
  caches_page :index

  #
  # caches_page :show
  #
  # FIXME: need to look into how to cache the parties page when
  # the issue list is enabled.
  #
  # * sweeper
  # * ActiveRecord::Observer
  #
  # The party page must be expired on:
  #
  # * issue saved
  # * issue's vote_connection updated
  # * issue's vote_connection added
  # * issue's vote_connection removed
  #
  # Also need to find a way to test this.
  #

  def index
    @parties = Party.order(:name).all

    respond_to do |format|
      format.html
      format.json { render json: @parties }
      format.xml  { render xml:  @parties }
    end
  end

  def show
    @party  = Party.includes(:representatives).find(params[:id])
    @representatives = @party.current_representatives

    @issues = Issue.published.order(:title)
    @categories = Category.where(:main => true).includes(:children => :promises)

    respond_to do |format|
      format.html
      format.json { render json: @party }
      format.xml  { render xml:  @party }
    end
  end

end
