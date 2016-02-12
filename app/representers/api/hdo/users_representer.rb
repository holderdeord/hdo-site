module Api
  module Hdo
    class UsersRepresenter < BaseRepresenter
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