module Api
  class BaseRepresenter < Roar::Decorator
    include Roar::Representer::JSON::HAL
  end
end
