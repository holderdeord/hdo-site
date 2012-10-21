require 'loadable_component'

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

    def text
      wait_until {
        driver.find_element(tag_name: 'body')
      }.text
    end

    def wait_until(timeout = 10, &blk)
      Selenium::WebDriver::Wait.new(:timeout => timeout).until(&blk)
    end
  end
end