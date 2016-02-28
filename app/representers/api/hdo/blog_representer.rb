module Api
  module Hdo
    class BlogRepresenter < BaseRepresenter
      collection :to_a,
          embedded: true,
          name: :posts,
          as: :posts
    end
  end
end