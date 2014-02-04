module Hdo
  module Utils
    class PropositionsFeed

      attr_reader :title, :height

      def self.for_party(party, opts = {})
        propositions = party.propositions.includes(:votes, :proposition_endorsements => :proposer)
        propositions = propositions.published.order('created_at DESC').first(opts.delete(:count) || 5)

        new(propositions, {title: "Siste forslag fra #{party.name}"}.merge(opts))
      end

      def self.for_representative(representative, opts = {})
        propositions = representative.propositions.includes(:votes, :proposition_endorsements => :proposer)
        propositions = propositions.published.order('created_at DESC').first(opts.delete(:count) || 10)

        new(propositions, {title: "Siste forslag fra #{representative.first_name}"}.merge(opts))
      end

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
        @propositions.map(&:decorate)
      end

    end
  end
end