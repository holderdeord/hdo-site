# encoding: utf-8

module Hdo
  module Charts

    # TODO: clean this up
    class Activity
      def initialize(name, results)
        @name = name
        @grouped = results.group_by { |e| e.vote.time.midnight }

        @start = Time.parse("2011-10-01").utc.midnight
        @stop = Time.parse("2012-07-01").utc.midnight

        @all = ::Vote.personal.where(:time => @start..@stop).group_by { |v| v.time.midnight }
        @results = results.select { |r| r.vote.time.utc.between?(@start, @stop) }
      end

      def presence
        series = []
        each_weekday(@start, @stop) do |time|
          series << [time.to_i * 1000, score_for(time)]
        end

        {
          # TODO: i18n
          title: "Aktivitet på Stortinget 2011-2012",
          subtitle: %Q{Basert på #{@results.size} voteringer for #{@name}},
          credits: I18n.t('app.url'),
          series: [
            { name: 'Prosent tilstede', data: series }
          ]
        }
      end

      def votes
        grouped = @results.group_by { |e| e.result }
        build_series = lambda do |r|
          [r.vote.time.utc.to_i * 1000, r.result]
        end

        absent = Array(grouped[0]).map(&build_series)
        against = Array(grouped[-1]).map(&build_series)
        infavor = Array(grouped[1]).map(&build_series)

        {
          title: '',
          subtitle: '',
          credits: I18n.t('app.url'),
          series: [
            { name: I18n.t('app.absent'), data: absent },
            { name: I18n.t('app.against'), data: against },
            { name: I18n.t('app.for'), data: infavor },
          ]
        }
      end

      private

      def score_for(time)
        vote_results = @grouped[time]
        votes = @all[time]

        if vote_results
          (vote_results.select { |e| e.present? }.size / votes.size.to_f) * 100
        else
          0
        end
      end

      def each_weekday(start, stop, &blk)
        weekend = [0, 6]

        while start <= stop
          yield start unless weekend.include?(start.wday)
          start += 1.day
        end
      end
    end

  end
end