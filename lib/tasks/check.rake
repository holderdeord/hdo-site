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

  desc 'Check that promises in the given JSON file has the correct categories'
  task :categories => :environment do
    file = ENV['PROMISES'] or raise "please set PROMISES=/path/to/promises.json"
    require 'hdo/storting_importer'

    promises = Hdo::StortingImporter::Promise.from_json(File.read(file))
    failed = false

    promises.each do |promise|
      missing = promise.categories.reject { |e| Category.find_by_name(e) }
      if missing.any?
        failed = true
        puts "promise #{promise.external_id}: invalid categories #{missing.inspect}"
      end
    end

    if failed
      raise "found missing categories"
    end
  end
end

task :check => %w[check:tabs check:scss]