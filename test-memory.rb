def run_agreement
  config = {
    unit: :propositions,
    ignore_unanimous: true,
    votes: ParliamentSession.current.votes.first(100)
  }

  # Hdo::Stats::AgreementScorer.new(config).result  
  config[:votes].first(10).map(&:stats)
  p ObjectSpace.each_object.reduce(Hash.new(0)) { |a, e| a[e.class.to_s] += 1; a }['VoteResult']

  # .map { |e| 
  #   e.stats 
  #   p e.id => ObjectSpace.each_object.reduce(Hash.new(0)) { |a, e| a[e.class.to_s] += 1; a }['VoteResult']
  # }
end

def mb_used
  (`ps -o rss= -p #{Process.pid}`.to_i * 1024).to_f / 2**20
end

Rails.cache.clear

mb_before = mb_used
time_before = Time.now
run_agreement
time_after = Time.now
mb_after = mb_used


p(mb_before: mb_before, mb_after: mb_after, used: mb_after - mb_before, time_used: time_after - time_before)

# ObjectSpace.each_object.reduce(Hash.new(0)) { |a, e| a[e.class.to_s] += 1; a }.select { |name, count| count > 1 }.sort_by { |name, count| -count }.each { |name, count| puts "#{count.to_s.ljust(15)}: #{name}"}
