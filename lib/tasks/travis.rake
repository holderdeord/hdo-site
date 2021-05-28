namespace :travis do
  task :status do
    require 'json'
    require 'faraday'

    data = JSON.parse(Faraday.get("https://api.travis-ci.org/repositories/holderdeord/hdo-site.json").body)
    time = data['last_build_finished_at'] || data['last_build_started_at']

    status = case data['last_build_status']
             when nil
               'running'
             when 0
               'passing'
             else
               'failing'
             end


    puts "#{data['slug']}: #{status} @ #{Time.parse(time).localtime}"
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
  spec:coverage:ensure
]

