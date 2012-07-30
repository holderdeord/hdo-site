module Pages
  class Menu
    def initialize(driver)
      @driver = driver
    end

    def open_votes
      open_stortinget
      navbar_element.find_element(css: 'a[href="/votes"]').click
    end

    private

    def open_stortinget
      navbar_element.find_element(:css, 'a[href="#stortinget"]').click
    end

    def navbar_element
      @driver.find_element :class, 'navbar'
    end
  end

  module HasMenu
    def menu
      Menu.new driver
    end
  end
end