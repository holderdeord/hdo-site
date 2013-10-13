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
    task :dump => ['tmp/db.download.sql', :verify] do
      puts "Importing production dump"

      un = YAML.load_file(Rails.root.join('config/database.yml'))['development']['username']

      if un
        sh "psql -U #{un} hdo_development < tmp/db.download.sql"
      else
        sh "psql hdo_development < tmp/db.download.sql"
      end
    end

    REMOTE_DUMP = "http://files.holderdeord.no/dev/data/db.dev.sql"
    LOCAL_DUMP  = 'tmp/db.download.sql'

    file LOCAL_DUMP do |t|
      puts "Downloading DB dump from #{REMOTE_DUMP}..."
      sh "curl", REMOTE_DUMP, "--create-dirs", "--output", t.name
    end

    task :verify do
      expected = `curl #{REMOTE_DUMP}.md5`.strip
      actual   = `cat #{LOCAL_DUMP} | openssl md5`.strip[/[a-z0-9]{32}/]

      if expected != actual
        raise "bad db dump checksum: #{expected.inspect} != #{actual.inspect}, remove #{LOCAL_DUMP} and try again"
      end
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