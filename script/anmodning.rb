require 'csv'
require 'json'
require 'pp'

data = []

if ARGV.first == 'cached'
  data = JSON.parse(File.read('anmodning.json'))
else
  props = Proposition.where('body like ? or body like ?', '%Stortinget ber regjering%', '%Stortinget anmoder regjering%')
  by_period = props.group_by { |e| e.parliament_period_name }

  selected_periods = ['2013-2017', '2009-2013']

  data = selected_periods.flat_map do |period|
      (by_period[period] || []).flat_map do |prop|
        vote = prop.votes.first

        {
          url: "https://data.holderdeord.no/propositions/#{prop.id}",
          session: prop.parliament_session_name,
          body: prop.body,
          vote_date: prop.vote_time.strftime('%Y-%m-%d'),
          vote_enacted: vote.try(:enacted),
          vote_proposer_guess: prop.source_guess,
          vote_proposers: prop.proposers.map(&:name),
          vote_for: (vote.stats.groups[:for] || []),
          vote_against: (vote.stats.groups[:against] || []),
          vote_absent: (vote.stats.groups[:absent] || []),
        }
    end
  end

  File.open("anmodning.json", "w") { |file| file << data.to_json }
  data = JSON.parse(data.to_json) # stringify keys
end

# STDOUT << CSV.generate(col_sep: "\t") do |csv|
# csv << [
#     'url',
#     'session',
#     'body',
#     'vote_date',
#     'vote_enacted',
#     'proposer_guess',
#     'proposers',
#     'parties_for',
#     'parties_against',
#     'parties_absent',
#   ]

#   data.each do |e|
#     csv << [
#       e[:url],
#       e[:session],
#       e[:body],
#       e[:vote_date],
#       e[:vote_enacted],
#       e[:vote_proposer_guess],
#       e[:vote_proposers],
#       e[:vote_for],
#       e[:vote_against],
#       e[:vote_absent]
#     ]
#   end
# end

by_session = data.group_by { |e| e['session'] }

total_counts_by_session = Hash.new { |hash, key| hash[key] = {total: 0, enacted: 0} }
party_counts_by_session = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = {total: 0, enacted: 0}}}

by_session.each do |session, props|
  props.each do |prop|
    total_counts_by_session[session][:total] += 1
    total_counts_by_session[session][:enacted] += 1 if prop['vote_enacted']

    prop['vote_for'].each do |party|
      party_counts_by_session[session][party['name']][:total] += 1
      party_counts_by_session[session][party['name']][:enacted] += 1 if prop['vote_enacted']
    end
  end
end

File.open("anmodning-totals.tsv", "w") { |io|
  io << CSV.generate(col_sep: "\t") do |csv|
    csv << ['session', 'total', 'vedtatt']

    total_counts_by_session.sort_by { |session, counts| session }.each do |session, counts|
      csv << [session, counts[:total], counts[:enacted]]
    end
  end
}

File.open("anmodning-parties.tsv", "w") { |io|
  io << CSV.generate(col_sep: "\t") do |csv|
    csv << ['session', 'parti', 'total', 'vedtatt']

    party_counts_by_session.sort_by { |session, counts| session }.each do |session, counts|
      counts.each do |party, party_counts|
        csv << [session, party, party_counts[:total], party_counts[:enacted]]
      end
    end
  end
}

# pp total_counts_by_session
# pp party_counts_by_session