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

    @latest_votes = fetch_latest_votes(12)
  end

  private

  def fetch_latest_votes(count)
    vote_results = @representative.vote_results.joins(:vote => :propositions).
                                   where('propositions.status' => 'published').
                                   where('result != 0').uniq.
                                   first(count)


    latest = vote_results.flat_map do |result|
      propositions = result.vote.propositions.select { |prop| prop.published? && prop.interesting? }
      propositions.map do |proposition|
        position = result.human

        desc = proposition.simple_description
        desc = "#{UnicodeUtils.downcase desc[0]}#{desc[1..-1]}"

        [position, desc, proposition]
      end
    end

    latest.first(count)
  end
end
