class SessionsController < Devise::SessionsController
  AppConfig.ssl_enabled && force_ssl(host: AppConfig.ssl_host)
end