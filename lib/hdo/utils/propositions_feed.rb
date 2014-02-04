module Hdo
  module Utils
    class PropositionsFeed

      attr_reader :title, :height

      def initialize(propositions, opts = {})
        @propositions = propositions

        @title   = opts[:title] || 'Siste forslag fra Stortinget'
        @see_all = !!opts[:see_all]
        @height  = opts[:height]
      end

      def empty?
        @propositions.empty?
      end

      def any?
        @propositions.any?
      end

      def edit?
        @edit
      end

      def see_all?
        @see_all
      end

      def propositions
        @propositions.map { |e| PropositionDecorator.new e }
      end

      class PropositionDecorator < Draper::Decorator
        delegate :id, :to_param

        def title
          str = model.simple_description || model.description
          "#{UnicodeUtils.upcase str[0]}#{str[1..-1]}"
        end

        def timestamp
          ltime = model.vote_time.localtime
          if ltime > 1.week.ago
            "#{h.distance_of_time_in_words_to_now(ltime)} siden"
          else
            h.l ltime, format: :short_text
          end
        end

        def proposers
          @proposers ||= model.proposers.map(&:name).sort
        end
      end

    end
  end
end