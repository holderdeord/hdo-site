require 'csv'

parties = Party.all.to_a

output = "votes.tsv"

File.open(output, "w") do |file|
  file << CSV.generate(col_sep: "\t") do |csv|
    csv << [
      'periode',
      'sesjon',
      'votering_tid',
      'votering_id',
      'forslag_id',
      'votering_beskrivelse',
      'forslag_beskrivelse',
      'antall_for',
      'antall_mot',
      'antall_ikke_tilstede',
      'personlig',
      'vedtatt',
      'enstemmig',
      *parties.map { |p| p.external_id  }
    ]

    ParliamentSession.all.each do |session|
      session.votes.each.with_index do |vote, index|
        if index % 10 == 0
          p [session.name, index]
        end

        stats = vote.stats

        vote.propositions.each do |prop|
          row = [
            vote.parliament_period.name,
            session.name,
            vote.time,
            vote.id,
            prop.id,
            vote.subject,
            prop.description,
            stats.for_count,
            stats.against_count,
            stats.absent_count,
            vote.personal?,
            vote.enacted?,
            stats.unanimous?,
            *parties.map { |p| stats.key_for(p) }
          ]

          csv << row
        end
      end
    end
  end
end

puts "Wrote #{output}"