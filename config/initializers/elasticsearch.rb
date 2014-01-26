# TODO: typhoeus or net_http_persistent transport

file = Rails.root.join("log/elasticsearch_#{Rails.env}.log").open('a')
file.binmode

logger = ActiveSupport::BufferedLogger.new(file)

options = {
  hosts: Array(AppConfig.elasticsearch_url),
  log: true,
  logger: logger,
  retry_on_failure: 2
}

Elasticsearch::Model.client = Elasticsearch::Client.new options
# Elasticsearch::Model.index_prefix "hdo_#{Rails.env}"

SearchSettings = Hdo::Search::Settings
