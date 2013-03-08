module Hdo
  module Utils
    module Uploader
      include CarrierWave::MiniMagick
      include Sprockets::Helpers::RailsHelper
      include Sprockets::Helpers::IsolatedHelper
    end
  end
end