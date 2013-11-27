# encoding: utf-8

module Hdo
  class NewIssue
    delegate :title, :description, :tags, :to_param, to: :@issue

    def initialize(issue)
      @issue = issue
    end

    def updated_at
      I18n.l @issue.updated_at, format: :text
    end

    def explanation
      pcs = proposition_connections.map(&:vote).uniq

      count = pcs.size
      start_date = pcs.last.time
      end_date = pcs.first.time

      "#{count} avstemninger på Stortinget mellom #{start_date} og #{end_date}"
    end

    def periods
      periods = [ParliamentPeriod.named('2013-2017'), ParliamentPeriod.named('2009-2013')]
      periods.map { |pp| Period.new(pp, @issue) }.select { |e| e.years.any? && e.positions.any? }
    end

    private

    class Period
      delegate :name, to: :@parliament_period

      def initialize(parliament_period, issue)
        @parliament_period = parliament_period
        @issue             = issue
      end

      def years
        @years ||= @issue.proposition_connections.select { |e| @parliament_period.include?(e.vote.time) }.
               group_by { |e| e.vote.time.to_date }.
               map { |date, connections| Day.new(date, connections) }.
               sort_by(&:raw_date).reverse.group_by { |e| e.year }.
               map { |year, days| OpenStruct.new(:year => year, :days => days) }
      end

      def positions
        @positions ||= @issue.positions.where(parliament_period_id: @parliament_period).order(:priority).map { |pos| Position.new(@issue, pos) }
      end
    end

    class Position
      delegate :title, :description, to: :@position

      def initialize(issue, position)
        @issue    = issue
        @position = position
        @period   = position.parliament_period
      end

      def parties
        @position.parties.map { |party| PartyInfo.new(party, comment_for(party), promises_for(party), accountability_for(party)) }
      end

      private

      def promises_for(party)
        @issue.promise_connections.joins(:promise).
                where('promises.promisor_id' => party).
                where('promises.promisor_type' => Party.name).
                where('promises.parliament_period_id' => @period).
                sort_by(&:status)
      end

      def accountability_for(party)
        @issue.accountability.text_for(party)
      end

      def comment_for(party)
        @issue.party_comments.
               where(:party_id => party).
               where(:parliament_period_id => @period).first
      end
    end

    class PartyInfo < Struct.new(:party, :comment, :promises, :accountability)
      delegate :logo, :slug, :name, to: :party
    end

    class Day
      def initialize(date, connections)
        @date = date
        @connections = connections
      end

      def day
        @date.day
      end

      def year
        @date.year
      end

      def month
        I18n.l @date, format: '%b'
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
