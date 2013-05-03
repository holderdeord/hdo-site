class SessionsController < Devise::SessionsController
  force_fastly_ssl
end