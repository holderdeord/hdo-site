require 'will_paginate/array'

class VotesController < ApplicationController
  caches_page :show

  def index
    @issues = Issue.includes(:votes).select { |issue| issue.has_votes? }
      .paginate(:page => params[:page], :per_page => params[:per_page] || 25)
    @votes = Vote.includes(:issues).order(:time).reverse_order

    respond_to do |format|
      format.html
      format.json { render json: @votes }
      format.xml  { render xml:  @votes }
    end
  end

  def show
    @vote = Vote.includes(
      :issues, :vote_results => {:representative => :party},
    ).find(params[:id])

    @issues = @vote.issues
    @stats  = @vote.stats

    respond_to do |format|
      format.html
      format.json { render json: @vote }
      format.xml  { render xml:  @vote }
    end
  end
end
