namespace :facebook do
  task :likes => :environment do
    Hdo::Utils::FacebookStats.new.display
  end
end