# encoding: utf-8

class IssueDecorator < Draper::Decorator
  delegate :title,
           :description,
           :tags,
           :to_param,
           :status_text,
           :editor_name,
           :last_updated_by_name,
           :published?

  def updated_at
    I18n.l model.updated_at, format: :text
  end

  def time_since_updated
    h.distance_of_time_in_words_to_now model.updated_at.localtime
  end

  def periods
    periods = [ParliamentPeriod.named('2013-2017'), ParliamentPeriod.named('2009-2013')].compact
    periods.map { |pp| Period.new(pp, model) }.select { |e| e.years.any? }
  end

  def period_named(name)
    periods.find { |e| e.name == name }
  end

  def short_explanation
    h.t 'app.votes.based_on', count: model.proposition_connections.size
  end

  private

  class Period
    delegate :name, to: :@parliament_period

    def initialize(parliament_period, issue)
      @parliament_period = parliament_period
      @issue             = issue
    end

    def years
      @years ||= proposition_connections.group_by { |e| e.vote.time.to_date }.
             map { |date, connections| Day.new(date, connections) }.
             sort_by(&:raw_date).reverse.group_by { |e| e.year }.
             map { |year, days| OpenStruct.new(:year => year, :days => days) }
    end

    def promisors
      @promises ||= @issue.promise_connections.joins(:promise).
                      where('promises.parliament_period_id' => @parliament_period).
                      group_by { |e| e.promise.promisor }.
                      sort_by { |promisor, _| [promisor.kind_of?(Party) ? 0 : 1, promisor.name] }.
                      map { |promisor, connections| Promisor.new(promisor, connections) }

    end


    def positions
      @positions ||= @issue.positions.where(parliament_period_id: @parliament_period).order(:priority).map { |pos| Position.new(@issue, pos) }
    end

    def explanation
      votes = proposition_connections.map(&:vote).uniq

      count      = votes.size
      start_date = votes.first.time
      end_date   = votes.last.time

      "Basert på #{count} avstemning#{count == 1 ? '' : 'er'} på Stortinget mellom #{I18n.l start_date, format: :month_year} og #{I18n.l end_date, format: :month_year}"
    end

    private

    def proposition_connections
      @proposition_connections ||= @issue.proposition_connections.select { |e| @parliament_period.include?(e.vote.time) }.sort_by { |e| e.vote.time }
    end
  end

  class Position
    delegate :title, :description, :priority, to: :@position

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
      promises = @issue.promise_connections.joins(:promise).
                    where('promises.promisor_id' => party).
                    where('promises.promisor_type' => Party.name).
                    where('promises.parliament_period_id' => @period)

      #
      # The following may need change if there are several governments per period.
      #

      gov = Government.for_date(@period.start_date + 2.months).first
      if gov && gov.parties.include?(party)
        promises += @issue.promise_connections.joins(:promise).
                      where('promises.promisor_id' => gov).
                      where('promises.promisor_type' => Government.name).
                      where('promises.parliament_period_id' => @period)
      end

      promises.sort_by(&:status)
    end

    def accountability_for(party)
      @issue.accountability(@period).text_for(party)
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

  class Promisor < Struct.new(:promisor, :connections)
    def parties
      promisor.kind_of?(Government) ? promisor.parties : [promisor]
    end

    def teaser
      connections.first.promise.body.truncate(100)
    end
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
