module Api
  module Hdo
    class UsersRepresenter < BaseRepresenter
      link :find do
        {
          href: templated_url(:api_hdo_user_url, id: 'id'),
          templated: true
        }
      end

      link :self do
        api_hdo_users_url
      end

      collection :to_a,
          embedded: true,
          name: :users,
          as: :users,
          extend: UserRepresenter

    end
  end
end