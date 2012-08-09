namespace :import do
  desc 'Import a subset of data for development'
  task :dev do
    sh "script/import", "dev"
  end

  desc 'Import promises'
  task :promises => %w[db:clear:promises] do
    sh "hdo-converter promises http://files.holderdeord.no/promises.csv | script/import json -"
  end
end