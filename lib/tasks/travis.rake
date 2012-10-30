namespace :travis do
  task :status do
    require 'json'
    require 'faraday'

    data = JSON.parse(Faraday.get("https://travis-ci.org/holderdeord/hdo-site.json").body)
    puts "#{data['slug']}: #{data['last_build_status'] == 0 ? 'passing' : 'failing'} @ #{Time.parse(data['last_build_finished_at']).localtime}"
  end
end

desc 'Run the full Travis build'
task :travis => %w[
  check
  db:create
  db:migrate
  tmp:create
  spec
  js:test
  js:lint
  spec:coverage:ensure
]

