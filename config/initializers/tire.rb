Tire.configure do
  logger Rails.root.join("log/tire_#{Rails.env}.log")
end

TireSettings = Hdo::Search::Settings
