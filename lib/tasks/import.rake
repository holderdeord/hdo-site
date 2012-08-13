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
      Hdo::Import::CLI.new(['json', "http://files.holderdeord.no/dev/promises.json"]).run
    end
  end

  desc 'Import a subset of data for development'
  task :dev => %w[import:dev:parliament import:dev:promises]

  desc 'Import all promises. Requires API key to access the master table.'
  task :promises  => "import:env" do
    Hdo::Import::CLI.new(['promises']).run
  end

  desc 'Import default session votes from the API'
  task :votes => "import:env" do
    Hdo::Import::CLI.new(['votes']).run
  end

  desc 'Import the default session from the API'
  task :api => "import:env" do
    Hdo::Import::CLI.new(['api']).run
  end

end