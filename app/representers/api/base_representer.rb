module Api
  class BaseRepresenter < Roar::Decorator
    include Roar::Representer::JSON::HAL

    def templated_url(name, *args)
      url_opts = {}
      opts = args.last.kind_of?(::Hash) ? args.pop : {}

      opts.each_key do |key|
        url_opts[key] = "__#{key}__"
      end

      args.push(url_opts)

      url = __send__(name, *args)
      url_opts.each do |key, value|
        url.gsub!(value, "{#{opts[key]}}")
      end

      url
    end

  end
end
