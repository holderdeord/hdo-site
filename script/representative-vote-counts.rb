require 'csv'

reps = Hash.new { |hash, key| hash[key] = {representative: nil, counts: {for: 0, against: 0, absent: 0}} }

ParliamentPeriod.named('2013-2017').votes.includes(:vote_results => :representative).each do |vote|
  vote.vote_results.each do |vr|
    reps[vr.representative.external_id][:representative] = vr.representative
    reps[vr.representative.external_id][:counts][vr.state] += 1
  end
end


STDOUT << CSV.generate(col_sep: "\t") do |csv|
  csv << ['Navn', 'Antall for', 'Antall mot', 'Antall ikke tilsted']

  reps.each do |external_id, data|
    csv << [data[:representative].name, data[:counts][:for], data[:counts][:against], data[:counts][:absent]]
  end
end
