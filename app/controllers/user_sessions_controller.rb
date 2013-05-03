class UserSessionsController < Devise::SessionsController
  force_fastly_ssl
end