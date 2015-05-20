module Hdo
  module Utils
    class PropositionsFeed

      attr_reader :title, :height

      def self.for_model(model, opts = {})
        propositions = model.propositions.includes(:votes, :proposition_endorsements => :proposer)
        propositions = propositions.published.order('created_at DESC').first(opts.delete(:count) || 10)

        new(propositions, opts)
      end

      def initialize(propositions, opts = {})
        @propositions = propositions

        @title          = opts[:title] || 'Siste forslag fra Stortinget'
        @see_all        = !!opts[:see_all]
        @height         = opts[:height]
        @show_parties   = !!opts[:show_parties]
        @show_proposers = !!opts[:show_proposers]
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
        @propositions.map(&:decorate)
      end

      def show_parties?
        @show_parties
      end

      def show_proposers?
        @show_proposers  
      end

    end
  end
end