namespace :graphite do
  task :env => :environment do
    require 'hdo/stats/accountability_scorer'
  end


  task :facebook => :env do
    g = Hdo::Utils::GraphiteReporter.instance

    Hdo::Utils::FacebookStats.new.stats.each do |key, value|
      g.add key, value
    end
  end

  task :stortinget => :env do
    g = Hdo::Utils::GraphiteReporter.instance

    g.add 'stortinget.count.votes',           Vote.count
    g.add 'stortinget.count.propositions',    Proposition.count
    g.add 'stortinget.count.issues',          ParliamentIssue.count
    g.add 'stortinget.count.representatives', Representative.count
  end

  task :holderdeord => :env do
    g = Hdo::Utils::GraphiteReporter.instance

    g.add 'hdo.count.issues.total',               Issue.count
    g.add 'hdo.count.issues.published',           Issue.published.count

    g.add 'hdo.count.promises.total',             Promise.count
    g.add 'hdo.count.promises.connected',         PromiseConnection.includes(:issue).where("issues.status" => "published").select(:promise_id).count
    g.add 'hdo.count.propositions.connected',     PropositionConnection.includes(:issue).where("issues.status" => "published").select(:proposition_id).count

    g.add 'hdo.count.representatives.opted_out',  Representative.opted_out.count
    g.add 'hdo.count.representatives.registered', Representative.registered.count

    previous_period = ParliamentPeriod.previous
    current_period  = ParliamentPeriod.current
    current_session = ParliamentSession.current

    [previous_period, current_period].each do |period|
      leaderboard = Hdo::Stats::Leaderboard.new(Issue.published, period)
      leaderboard.by_party.each do |party, counts|
        counts.each do |key, count|
          g.add "hdo.count.issues.#{period.name}.#{party.slug}.#{key}", count
        end
      end
    end

    counts = Hdo::Stats::PropositionCounts.from_session(current_session.name)

    g.add "hdo.count.propositions.#{current_session.name}.published", counts.published
    g.add "hdo.count.propositions.#{current_session.name}.pending", counts.pending
    g.add "hdo.count.propositions.#{current_session.name}.total", counts.total
  end

  task :submit => %w[facebook stortinget holderdeord] do
    Hdo::Utils::GraphiteReporter.instance.submit
  end

  task :print => %w[facebook stortinget holderdeord] do
    Hdo::Utils::GraphiteReporter.instance.print
  end
end
