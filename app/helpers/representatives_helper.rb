# encoding: utf-8

module RepresentativesHelper

  # TODO: class doesn't belong here
  class VoteStats
    def initialize(results)

      # FIXME: This is because of the specially imported DLD vote. Get rid of this when we have the full session.
      if results.any?
        results = results[1..-1] if results.first.vote.time.strftime("%Y-%m-%d") == "2011-04-04"
      end

      @grouped = results.group_by { |e| e.result }

      @for     = @grouped[1] || []
      @absent  = @grouped[0] || []
      @against = @grouped[-1] || []

      @subtitle = "Basert på #{results.size} voteringer"
      @subtitle << %Q{ mellom #{I18n.l results.first.vote.time, format: :short} og #{I18n.l results.last.vote.time, format: :short}}
    end

    def as_json(opts = nil)
      {
        # TODO: i18n
        title: 'Aktivitet på Stortinget',
        subtitle: @subtitle,
        series: [
          { name: I18n.t('app.absent'), data: build_data(@absent) },
          { name: I18n.t('app.against'), data: build_data(@against) },
          { name: I18n.t('app.for'), data: build_data(@for) },
        ]
      }
    end

    private

    def build_data(results)
      results.map do |r|
        [r.vote.time.utc.to_i * 1000, r.result]
      end
    end
  end
end
