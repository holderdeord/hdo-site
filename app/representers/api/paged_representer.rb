module Api
  class PagedRepresenter < BaseRepresenter
    property :total_count, as: :total
    property :count
    property :total_pages
    property :current_page

    link :self do |opts|
      if represented.current_page == 1
        url_helper(url_params_for(opts))
      else
        url_helper(url_params_for(opts).merge(page: represented.current_page))
      end
    end

    link :next do |opts|
      url_helper(url_params_for(opts).merge(page: represented.next_page)) if represented.next_page
    end

    link :prev do |opts|
      url_helper(url_params_for(opts).merge(page: represented.prev_page)) if represented.prev_page
    end

    link :last do |opts|
      url_helper(url_params_for(opts).merge(page: represented.total_pages)) if represented.total_pages > 1
    end

    private

    def url_helper(*args)
      # we may actually be able to do a generic version here
      raise NotImplementedError, "subclass responsibility"
    end

    def url_params_for(opts)
      # may be overriden by subclasses
      {}
    end

  end
end
