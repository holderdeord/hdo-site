namespace :import do
  task :env => :environment do
    require 'hdo/import'
  end

  namespace :dev do
    desc 'Import a subset of parliament data for development'
    task :parliament => "import:env" do
      Hdo::Import::CLI.new(['dev']).run
    end

    desc 'Import a subset of promises for development'
    task :promises => %w[db:clear:promises import:env] do
      Hdo::Import::CLI.new(['json', "http://files.holderdeord.no/dev/data/promises.dev.json"]).run
    end

    desc 'Import a (reduced) production dump to the development db'
    task :dump => 'tmp/db.download.sql' do
      puts "Importing production dump"
      sh "psql hdo_development < tmp/db.download.sql"
    end

    file 'tmp/db.download.sql' do |t|
      puts "Downloading DB dump..."
      sh "curl", "-s", "http://files.holderdeord.no/dev/data/db.dev.sql", "--create-dirs", "--output", t.name
    end
  end

  desc 'Import a subset of data for development'
  task :dev => %w[import:dev:dump images:reset cache:precompute search:reindex]

  desc 'Import all promises. Set SPREADSHEET to the master .xlsx'
  task :promises  => "import:env" do
    ss = ENV['SPREADSHEET'] or raise "must set SPREADSHEET"
    Hdo::Import::CLI.new(['promises', ss]).run
  end

  desc 'Import default session votes from the API'
  task :votes => "import:env" do
    Hdo::Import::CLI.new(['votes']).run
  end

  desc 'Import the default session from the API'
  task :api => "import:env" do
    Hdo::Import::CLI.new(['api']).run
  end

  desc 'Run the daily import.'
  task :daily => "import:env" do
    Hdo::Import::CLI.new(['daily']).run
  end

  desc 'Import a DB dump from production (assumes SSH access)'
  task :dump do
    sh "ssh hdo@db2.holderdeord.no 'pg_dump --clean hdo_production | gzip' | gunzip | psql hdo_development"
  end
end