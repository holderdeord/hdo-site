if Rails.env.development?
  Rails.cache.logger = Rails.logger
end