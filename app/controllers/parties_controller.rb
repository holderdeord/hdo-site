class PartiesController < ApplicationController
  caches_page :index
  # hmm, no caching of parties#show. need a sweeper?

  def index
    @parties = Party.order(:name).all

    respond_to do |format|
      format.html
      format.json { render json: @parties }
      format.xml  { render xml:  @parties }
    end
  end

  def show
    @party = Party.includes(:representatives, :promises => :categories).find(params[:id])

    # TODO: proper feature toggling
    if Rails.application.config.topic_list_on_parties_show
      @topics = Topic.vote_ordered.limit(10)
    end

    respond_to do |format|
      format.html
      format.json { render json: @party }
      format.xml  { render xml:  @party }
    end
  end

end
