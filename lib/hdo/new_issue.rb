# encoding: utf-8

require 'forwardable'

module Hdo
  class NewIssue
    extend Forwardable

    def_delegators :@issue, :title,
                           :description,
                           :updated_at,
                           :tags


    def initialize(issue)
      @issue = issue
    end

    def explanation
      vcs = vote_connections

      count = vcs.size
      start_date = vcs.last.time
      end_date = vcs.first.time

      "#{count} avstemninger på Stortinget mellom #{start_date} og #{end_date}"
    end

    def vote_connections
      @issue.vote_connections.sort_by { |e| e.vote.time }.reverse
    end

    def periods
      periods = [ParliamentPeriod.named('2013-2017'), ParliamentPeriod.named('2009-2013')]

      periods.map do |period|
        OpenStruct.new(name: period.name, days: days_for(period), positions: positions_for(period))
      end
    end

    private

    def days_for(period)
      @issue.vote_connections.group_by { |e| e.vote.time.to_date }.
             map { |date, connections| Day.new(date, connections) }.
             sort_by(&:raw_date).reverse
    end

    def positions_for(period)
      @issue.valence_issue_explanations.order(:priority).map { |e| Position.new(e) }
    end

    class Position # replaces ValenceIssueExplanation
      def initialize(vie)
        @vie = vie
      end

      def parties
        @vie.parties.order(:name)
      end

      def description
        @vie.explanation
      end

      def title
        @vie.title
      end
    end

    class Day
      def initialize(date, connections)
        @date = date
        @connections = connections
      end

      def date
        I18n.l @date, format: :text
      end

      def raw_date
        @date
      end

      def votes
        @connections.sort_by { |e| e.vote.time }.reverse
      end
    end
  end
end
