namespace :import do
  task :env => :environment do
    require 'hdo/import'
  end

  desc 'Import a subset of data for development'
  task :dev => "import:env" do
    Hdo::Import::CLI.new(['dev']).run
  end

  desc 'Import promises'
  task :promises => %w[db:clear:promises] do
    sh "hdo-converter promises http://files.holderdeord.no/promises.csv | script/import json -"
  end

  desc 'Import the default session from the API'
  task :votes => "import:env" do
    Hdo::Import::CLI.new(['votes']).run
  end

  desc 'Import the default session from the API'
  task :api => "import:env" do
    Hdo::Import::CLI.new(['api']).run
  end

end