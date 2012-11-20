require 'tire/http/clients/faraday'

Tire::Model::Search.index_prefix "hdo_#{Rails.env}"

Tire.configure do
  url    ENV['BONSAI_URL'] || AppConfig.elasticsearch_url
  logger Rails.root.join("log/tire_#{Rails.env}.log")

  Tire::HTTP::Client::Faraday.faraday_middleware = ->(fd) { fd.adapter :net_http_persistent }
  client Tire::HTTP::Client::Faraday
end

TireSettings = Hdo::Search::Settings
