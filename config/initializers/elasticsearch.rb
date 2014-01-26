# TODO: typhoeus or net_http_persistent transport

options = {
  hosts: AppConfig.elasticsearch_url.split(','),
  log: true,
  logger: Logger.new(Rails.root.join("log/elasticsearch_#{Rails.env}.log")),
  retry_on_failure: 2
}

Elasticsearch::Model.client = Elasticsearch::Client.new options
# Elasticsearch::Model.index_prefix "hdo_#{Rails.env}"

SearchSettings = Hdo::Search::Settings
