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

    @vote_feed = Hdo::Utils::RepresentativeVoteFeed.new(@representative, limit: 12)
  end
end
