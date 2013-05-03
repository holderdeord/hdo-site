class RepresentativeSessionsController < Devise::SessionsController
  force_fastly_ssl
end