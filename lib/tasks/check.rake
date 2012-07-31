namespace :check do
  desc 'Check tabs vs spaces'
  task :tabs do
    failures = `git ls-files`.split("\n").select do |path|
      next unless %w[.rb .less .css .js .erb].include? File.extname(path)

      print "."
      File.read(path).include? "\t"
    end
    puts

    unless failures.empty?
      raise "found tab characters in the following files:\n#{failures.join "\n"}"
    end
  end

  desc 'Check that no .scss files exist'
  task :scss do
    scss = Dir['**/*.scss']

    unless scss.empty?
      raise "found scss files:\n #{scss.join "\n"}"
    end
  end

  desc 'Check that promises in the given CSV file has the correct categories'
  task :categories => :environment do
    file = ENV['PROMISES'] or raise "please set PROMISES=/path/to.csv"
    require 'hdo/storting_importer'

    promises = Hdo::StortingImporter::Promise.from_csv(File.read(file))
    failures = []
    missing_categories = []

    promises.each do |promise|
      missing = promise.categories.reject { |e| Category.find_by_name(e) }
      if missing.any?
        failures << promise
        missing_categories += missing
      end
    end

    if failures.any?
      failures.each { |e| puts "#{e.party}: #{e.body} : #{e.categories.inspect} : #{e.source}:#{e.page}" }
      raise "found missing categories: #{missing_categories.uniq.sort.join "\n"}"
    end
  end
end

task :check => %w[check:tabs check:scss]