class RepresentativesController < ApplicationController
  hdo_caches_page :index, :show

  def index
    @representatives = Representative.includes(:district, party_memberships: :party).order(:last_name)
  end

  def show
    @representative = Representative.find(params[:id])
    @party          = @representative.latest_party

    @questions = @representative.questions.approved.sort_by do |q|
      (q.answer && q.answer.approved?) ? q.answer.created_at : q.created_at
    end.reverse

    per_page = 16
    offset = params[:page].to_i * per_page

    @vote_feed = Hdo::Utils::RepresentativeVoteFeed.new(
      @representative,
      limit: per_page,
      offset: offset
    )
  end
end
