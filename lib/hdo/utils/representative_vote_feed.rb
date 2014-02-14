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
          propositions = result.vote.propositions.select { |prop| prop.published? && prop.interesting? }
          propositions.map { |proposition| Entry.new(result, proposition) }
        end

        entries = entries.first(@limit) if @limit

        entries
      end

      private

      def vote_results
        vote_results = @representative.vote_results.includes(:vote => :propositions).
                                       where('propositions.status' => 'published').
                                       where('result != 0').
                                       order('votes.time desc').
                                       uniq


        vote_results = vote_results.limit(@limit) if @limit
        vote_results
      end

      class Entry
        attr_reader :proposition, :description, :position

        def initialize(result, proposition)
          @proposition = proposition

          @description = proposition.simple_description
          @description = "#{UnicodeUtils.downcase @description[0]}#{@description[1..-1]}" unless @description.empty?

          @position = result.human
        end
      end # Entry
    end # RepresentativeVoteFeed
  end
end
