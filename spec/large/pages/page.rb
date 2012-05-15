module Pages
  class Page
    include LoadableComponent

    attr_reader :driver

    def initialize(driver)
      @driver = driver
    end

    def current_path
      current_url.path
    end

    def current_url
      URI.parse driver.current_url
    end
  end
end