# encoding: utf-8

require 'forwardable'

module Hdo
  class NewIssue
    extend Forwardable

    def_delegators :@issue, :title,
                           :description,
                           :tags


    def initialize(issue)
      @issue = issue
    end

    def updated_at
      I18n.l @issue.updated_at, format: :text
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
      periods.map { |pp| Period.new(pp, @issue) }
    end

    private

    class Period
      def initialize(parliament_period, issue)
        @parliament_period = parliament_period
        @issue             = issue
      end

      def name
        @parliament_period.name
      end

      def days
        # TODO: make this actually check period
        @issue.vote_connections.group_by { |e| e.vote.time.to_date }.
               map { |date, connections| Day.new(date, connections) }.
               sort_by(&:raw_date).reverse
      end

      def positions
        # TODO: make this actually check period
        @issue.positions.order(:priority).map { |pos| Position.new(@issue, pos) }
      end
    end

    class Position
      extend Forwardable
      def_delegators :@position, :title, :description, :parties

      def initialize(issue, pos)
        @issue = issue
        @position = pos
      end

      def promises
        # TODO: optimize
        @issue.promise_connections.joins(:promise => :parties).where('parties.id' => @position.parties)
      end

      def accountability
        @position.parties.map { |e| @issue.accountability.text_for(e) }
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
