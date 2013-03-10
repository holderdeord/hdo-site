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

      # Strips out all embedded information from the image
      def strip
        manipulate! do |img|
          img.strip
          img = yield(img) if block_given?
          img
        end
      end

      # Reduces the quality of the image to the percentage given
      def quality(percentage)
        manipulate! do |img|
          img.quality(percentage.to_s)
          img = yield(img) if block_given?
          img
        end
      end

      def scale(width, height)
        manipulate! do |img|
          img.scale("#{width}x#{height}")
          img = yield(img) if block_given?
          img
        end
      end

      def crop(width, height, x, y)
        manipulate! do |img|
          img.crop("#{width}x#{height}+#{x}+#{y}")
          img = yield(img) if block_given?
          img
        end
      end

      def sharpen(radiux, sigma)
        manipulate! do |img|
          img.sharpen("#{radiux}x#{sigma}")
          img = yield(img) if block_given?
          img
        end
      end

      def sigmoidal_contrast(contrast, midpoint)
        manipulate! do |img|
          img.sigmoidal_contrast("#{contrast}x#{midpoint}%")
          img = yield(img) if block_given?
          img
        end
      end

    end
  end
end
