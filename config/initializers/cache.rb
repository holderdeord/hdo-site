unless Rails.env.production?
  Rails.cache.logger = Rails.logger
end

revision = Rails.root.join('REVISION')

if revision.exist?
  ENV['RAILS_CACHE_ID'] = revision.read[0,7]
end

if AppConfig.fastly_enabled && AppConfig.fastly_api_key.present?
  PageCache = Hdo::Utils::PageCache.fastly(Fastly.new(api_key: AppConfig.fastly_api_key))
else
  PageCache = Hdo::Utils::PageCache.dummy
end

