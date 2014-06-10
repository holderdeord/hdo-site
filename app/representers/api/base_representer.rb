module Api
  class BaseRepresenter < Roar::Decorator
    include Roar::Representer::JSON::HAL

    def templated_url(name, opts)
      url_opts = {}

      opts.each_key do |key|
        url_opts[key] = "__#{key}__"
      end

      url = __send__(name, url_opts)
      url_opts.each do |key, value|
        url.gsub!(value, "{#{opts[key]}}")
      end

      url
    end

  end
end
