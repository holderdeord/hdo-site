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

  desc 'Show positions in a diffable text format'
  task :positions => :environment do
    parties = Party.all
    representatives = Representative.all
    published = Issue.published

    published.each do |issue|
      stats = issue.stats
      acc = issue.accountability

      parties.each do |party|
        puts "party=#{party.slug.ljust(5)} | issue=#{issue.title}[#{issue.id}] | s=#{stats.score_for(party).inspect}"
        puts "party=#{party.slug.ljust(5)} | issue=#{issue.title}[#{issue.id}] | stext=#{stats.text_for(party).inspect}"
        puts "party=#{party.slug.ljust(5)} | issue=#{issue.title}[#{issue.id}] | a=#{acc.score_for(party).inspect}"
        puts "party=#{party.slug.ljust(5)} | issue=#{issue.title}[#{issue.id}] | atext=#{acc.text_for(party).inspect}"
      end

      representatives.each do |representative|
        puts "representative=#{representative.slug.ljust(5)} | issue=#{issue.title}[#{issue.id}] | #{stats.score_for(representative).inspect}"
        puts "representative=#{representative.slug.ljust(5)} | issue=#{issue.title}[#{issue.id}] | #{stats.key_for(representative).inspect}"
      end
    end
  end
end

task :check => %w[check:tabs]