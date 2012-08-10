unless Rails.env.production?
  Rails.cache.logger = Rails.logger
end