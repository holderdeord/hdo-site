require 'dragonfly/rails/images'

Dragonfly[:images].configure do |c|
  # TODO: check security implications of this.
  c.allow_fetch_file = true
end
