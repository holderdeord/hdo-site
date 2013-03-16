unless Rails.env.production?
  Rails.cache.logger = Rails.logger
end

revision = Rails.root.join('REVISION')

if revision.exist?
  ENV['RAILS_CACHE_ID'] = revision.read[0,7]
end