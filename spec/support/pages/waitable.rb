module Pages
  module Waitable
    def wait_until(timeout = 10, &blk)
      Selenium::WebDriver::Wait.new(:timeout => timeout).until(&blk)
    end
  end
end
