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

pp data.find { |e| (e['vote_for'] + e['vote_against'] + e['vote_absent']).any?(&:nil?) }

# all_parties = data.flat_map { |e| (e['vote_for'] + e['vote_against'] + e['vote_against']) }
# p all_parties