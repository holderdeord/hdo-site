namespace :hdo do
  namespace :promises do
    task :csv => :environment do
      require 'csv'

      promises = Promise.joins(:categories)

      if ENV['CATEGORIES']
        promises = promises.where('categories.name' => ENV['CATEGORIES'].split(','))
      end

      promises = promises.to_a.uniq.sort_by { |promise| promise.external_id.to_i }

      if ENV['OUT']
        out = File.open(ENV['OUT'], 'w')
      else
        out = STDOUT
      end

      CSV(out) do |csv|
        promises.each do |promise|
          csv << [
            promise.external_id,
            promise.categories.map(&:name).join(','),
            promise.body
          ]
        end
      end
    end
  end

  namespace :fake do
    task :dump => :environment do
      issue = Issue.find(161)
      decorator = issue.decorate

      data = issue.as_json(
        include: [
           { :tags => {methods: :slug}},
           { :vote_connections    => {:include => {:vote => {methods: :stats}}}},
           { :promise_connections => {:include => {:promise => {:include => :parties}}}},
           { :valence_issue_explanations => {:include => :parties}}
        ]
      )

      Rails.root.join('lib/hdo/fake_issue.json').open('w') do |io|
        io << JSON.pretty_generate(data.to_h)
      end
    end
  end
end