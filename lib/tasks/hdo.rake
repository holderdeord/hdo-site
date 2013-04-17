namespace :hdo do
  namespace :promises do
    task :csv => :environment do
      require 'csv'

      promises = Promise.joins(:categories)

      if ENV['CATEGORIES']
        promises = promises.where('categories.name' => ENV['CATEGORIES'].split(','))
      end

      if ENV['OUT']
        out = File.open(ENV['OUT'], 'w')
      else
        out = STDOUT
      end

      CSV(out) do |csv|
        promises.each do |promise|
          csv << [promise.external_id, promise.categories.map(&:name).join(','), promise.body]
        end
      end
    end
  end
end