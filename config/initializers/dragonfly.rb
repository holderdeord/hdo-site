require 'dragonfly/rails/images'

Dragonfly[:images].configure do |c|
  c.allow_fetch_file         = true
  c.protect_from_dos_attacks = true
  c.secret                   = Base64.strict_encode64(Random.new.bytes(32))
end
