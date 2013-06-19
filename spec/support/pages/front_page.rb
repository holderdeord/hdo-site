module Pages
  class FrontPage < Page
    include HasMenu

    def initialize(driver, url)
      super(driver)

      @url = url
    end

    def load
      driver.navigate.to @url
    end

    def loaded?
      driver.title == 'Holder de ord'
    end
  end
end