require 'dragonfly/rails/images'

Dragonfly[:images].configure do |c|
  c.allow_fetch_file         = true
  c.protect_from_dos_attacks = true
  c.secret                   = "YTHUqMUdv5N18fDvn64Yfq8YMkOHbgJZrVDgUmYs88Q="
end
