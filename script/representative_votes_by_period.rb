require 'csv'

rows = []

parliament_period = ARGV[0] || '2017-2021'
pp = ParliamentPeriod.named(parliament_period)

exit(1) unless pp

pp.votes.includes(vote_results: :representative).each do |vote|
  vote.vote_results.each do |vr|
    rows.push([
      vote.parliament_period.name,
      vote.parliament_session.name,
      vr.representative.name,
      vr.representative.party_at(vote.time).name,
      vr.state,
      vote.time,
      vote.id,
      vote.personal?,
      vote.enacted?
    ])
  end
end

STDOUT << CSV.generate(col_sep: "\t") do |csv|
  csv << [
    'periode',
    'sesjon',
    'representant_navn',
    'representant_stemme',
    'representant_parti',
    'votering_tid',
    'votering_id',
    'votering_beskrivelse',
    'personlig',
    'vedtatt',
  ]

  rows.each do |row|
    csv << row
  end
end
