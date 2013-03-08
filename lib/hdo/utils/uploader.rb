module Hdo
  module Utils
    module Uploader
      include CarrierWave::MiniMagick
      include Sprockets::Helpers::RailsHelper
      include Sprockets::Helpers::IsolatedHelper

      def digest(model_field)
        Rails.logger.warn "Digesting #{self.inspect}"
        checksum = Digest::MD5.hexdigest(model.__send__(model_field).read)

        "#{checksum}#{File.extname original_filename}"
      end
    end
  end
end