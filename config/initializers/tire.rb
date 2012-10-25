Tire.configure do
  logger Rails.root.join("log/tire_#{Rails.env}.log")
end

path = Rails.root.join('config/tire.yml')
TireSettings = YAML.load_file(path).with_indifferent_access