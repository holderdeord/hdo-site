module Hdo
  module ModelHelpers
    module HasFallbackImage
      def image_with_fallback
        self.image = Pathname.new(self.default_image) if self.image_uid == nil
        self.save! if self.image_uid_changed?
        self.image
      end
    end
  end
end