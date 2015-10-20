module Hdo
  module Utils
    class RepresentativeVoteFeed
      include Enumerable

      def initialize(representative, options = {})
        @representative = representative
        @limit          = options[:limit]
      end

      def entries
        entries = vote_results.flat_map do |result|
          propositions = result.vote.propositions.select(&:interesting?)
          propositions.map { |proposition| Entry.new(result, proposition) }
        end

        entries = entries.uniq_by { |e| e.description }
        entries = entries.first(@limit) if @limit

        entries
      end

      private

      def vote_results
        vote_results = @representative.vote_results.includes(:vote => {:propositions => :issues}).
                                       where('result != 0').
                                       order('votes.time desc').
                                       uniq


        vote_results = vote_results.limit(@limit) if @limit
        vote_results
      end

      class Entry
        attr_reader :proposition, :position

        def initialize(result, proposition)
          @proposition = proposition
          @position = result.human
        end

        def issues
          proposition.issues.published
        end

        def description
          @description ||= proposition.simple_description || proposition.auto_title
        end
      end # Entry
    end # RepresentativeVoteFeed
  end
end
