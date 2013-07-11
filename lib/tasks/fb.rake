namespace :facebook do
  task :likes => :environment do
    Hdo::Utils::FacebookStats.new.display
  end

  task :graphite => :environment do
    Hdo::Utils::FacebookStats.new.send_to_graphite
  end
end