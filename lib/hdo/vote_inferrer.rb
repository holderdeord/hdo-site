module Hdo
  #
  # This class deals with the problem of non-personal votes.
  #
  # This happens when the parliament doesn't use the voting system
  # to decide on an issue, but instead e.g. asks representatives to
  # rise if they disagree.
  #
  # If we have another vote from the same day, it's reasonable to assume
  # that the same set of representatives were present while the
  # non-personal vote was decided.
  #
  # Unfortunately, for some meetings, all votes will be non-personal.
  # These are ignored.
  #

  class VoteInferrer
    attr_accessor :log

    def initialize(votes = Vote.non_personal)
      @votes = votes
      @log   = Rails.logger
    end

    def infer!
      @votes.map do |vote|
        infer_result vote
      end
    end

    private

    def infer_result(vote)
      if vote.inferred?
        @log.info "#{self.class} ignoring vote #{vote.external_id} since results were already inferred"
        return false
      end

      personal_vote = find_personal_vote_for(vote.time)

      if personal_vote
        @log.info "#{self.class}: inferring result for vote #{vote.external_id} from #{personal_vote.external_id}"

        Vote.transaction do
          add_result vote, personal_vote
        end

        true
      else
        @log.info "#{self.class}: unable to infer result for vote #{vote.external_id}"
        false
      end
    end

    def find_personal_vote_for(time)
      personal_votes_of_the_day = Vote.personal.where("date(time) = date(?)", time)
      points = personal_votes_of_the_day.map { |v| v.time.to_i }
      clusterer = OnedimensionalHierarchicalClusterer.new(points, 900)
      cluster_for_time = [clusterer.nearest_cluster_for(time.to_i)].flatten
      personal_votes_of_the_day.select { |v| cluster_for_time.include? v.time.to_i }.first
    end

    def add_result(non_personal, personal)
      for_count, against_count, absent_count = 0, 0, 0

      personal.vote_results.each do |vote_result|
        if vote_result.absent?
          absent_count += 1
          result = 0
        elsif non_personal.enacted?
          for_count += 1
          result = 1
        else
          against_count += 1
          result = -1
        end

        non_personal.vote_results.create!(
          :representative => vote_result.representative,
          :result         => result
        )
      end

      non_personal.update_attributes!(
        :for_count     => for_count,
        :against_count => against_count,
        :absent_count  => absent_count
      )
    end
  end
end