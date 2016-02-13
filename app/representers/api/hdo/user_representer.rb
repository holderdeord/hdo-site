module Api
  module Hdo
    class UserRepresenter < BaseRepresenter
      property :name
      property :title
      property :description
      property :board
      property :image, exec_context: :decorator

      link :self do
        api_hdo_user_url represented
      end

      def image
        gravatar_url(represented.email)
      end

      private

      GRAVATAR_OVERRIDES = {
        'hilde.wibe@abelia.no' => '//data.holderdeord.no/assets/hdo/hilde-wibe.jpg'
      }

      def gravatar_url(email, opts = {})
        if GRAVATAR_OVERRIDES.key?(email)
          GRAVATAR_OVERRIDES[email]
        else
          default = 'https://www.holderdeord.no/assets/representatives/fallback_avatar.png'
          "//gravatar.com/avatar/#{Digest::MD5.hexdigest email}?s=300&d=#{URI.encode default}"
        end
      end

    end
  end
end